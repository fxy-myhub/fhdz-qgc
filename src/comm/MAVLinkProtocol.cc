/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include <inttypes.h>
#include <iostream>

#include <QDebug>
#include <QTime>
#include <QApplication>
#include <QSettings>
#include <QStandardPaths>
#include <QtEndian>
#include <QMetaType>
#include <QDir>
#include <QFileInfo>

#include "MAVLinkProtocol.h"
#include "UASInterface.h"
#include "UASInterface.h"
#include "UAS.h"
#include "LinkManager.h"
#include "QGCMAVLink.h"
#include "QGC.h"
#include "QGCApplication.h"
#include "QGCLoggingCategory.h"
#include "MultiVehicleManager.h"
#include "SettingsManager.h"

Q_DECLARE_METATYPE(mavlink_message_t)

QGC_LOGGING_CATEGORY(MAVLinkProtocolLog, "MAVLinkProtocolLog")

const char* MAVLinkProtocol::_tempLogFileTemplate   = "FlightDataXXXXXX";   ///< Template for temporary log file
const char* MAVLinkProtocol::_logFileExtension      = "mavlink";            ///< Extension for log files

/**
 * The default constructor will create a new MAVLink object sending heartbeats at
 * the MAVLINK_HEARTBEAT_DEFAULT_RATE to all connected links.
 */
MAVLinkProtocol::MAVLinkProtocol(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
    , m_enable_version_check(true)
    , _message({})
    , _status({})
    , versionMismatchIgnore(false)
    , systemId(255)
    , _current_version(100)
    , _radio_version_mismatch_count(0)
    , _logSuspendError(false)
    , _logSuspendReplay(false)
    , _vehicleWasArmed(false)
    , _tempLogFile(QString("%2.%3").arg(_tempLogFileTemplate).arg(_logFileExtension))
    , _linkMgr(nullptr)
    , _multiVehicleManager(nullptr)
{
    memset(totalReceiveCounter, 0, sizeof(totalReceiveCounter));
    memset(totalLossCounter,    0, sizeof(totalLossCounter));
    memset(runningLossPercent,  0, sizeof(runningLossPercent));
    memset(firstMessage,        1, sizeof(firstMessage));
    memset(&_status,            0, sizeof(_status));
    memset(&_message,           0, sizeof(_message));
}

MAVLinkProtocol::~MAVLinkProtocol()
{
    storeSettings();
    _closeLogFile();
}

void MAVLinkProtocol::setVersion(unsigned version)
{
    QList<SharedLinkInterfacePtr> sharedLinks = _linkMgr->links();

    for (int i = 0; i < sharedLinks.length(); i++) {
        mavlink_status_t* mavlinkStatus = mavlink_get_channel_status(sharedLinks[i].get()->mavlinkChannel());

        // Set flags for version
        if (version < 200) {
            mavlinkStatus->flags |= MAVLINK_STATUS_FLAG_OUT_MAVLINK1;
        } else {
            mavlinkStatus->flags &= ~MAVLINK_STATUS_FLAG_OUT_MAVLINK1;
        }
    }

    _current_version = version;
}

void MAVLinkProtocol::setToolbox(QGCToolbox *toolbox)
{
   QGCTool::setToolbox(toolbox);

   _linkMgr =               _toolbox->linkManager();
   _multiVehicleManager =   _toolbox->multiVehicleManager();

   qRegisterMetaType<mavlink_message_t>("mavlink_message_t");

   loadSettings();

   // All the *Counter variables are not initialized here, as they should be initialized
   // on a per-link basis before those links are used. @see resetMetadataForLink().

   connect(this, &MAVLinkProtocol::protocolStatusMessage,   _app, &QGCApplication::criticalMessageBoxOnMainThread);
   connect(this, &MAVLinkProtocol::saveTelemetryLog,        _app, &QGCApplication::saveTelemetryLogOnMainThread);
   connect(this, &MAVLinkProtocol::checkTelemetrySavePath,  _app, &QGCApplication::checkTelemetrySavePathOnMainThread);

   connect(_multiVehicleManager, &MultiVehicleManager::vehicleAdded, this, &MAVLinkProtocol::_vehicleCountChanged);
   connect(_multiVehicleManager, &MultiVehicleManager::vehicleRemoved, this, &MAVLinkProtocol::_vehicleCountChanged);

   emit versionCheckChanged(m_enable_version_check);
}

void MAVLinkProtocol::loadSettings()
{
    // Load defaults from settings
    QSettings settings;
    settings.beginGroup("QGC_MAVLINK_PROTOCOL");
    enableVersionCheck(settings.value("VERSION_CHECK_ENABLED", m_enable_version_check).toBool());

    // Only set system id if it was valid
    int temp = settings.value("GCS_SYSTEM_ID", systemId).toInt();
    if (temp > 0 && temp < 256)
    {
        systemId = temp;
    }
}

void MAVLinkProtocol::storeSettings()
{
    // Store settings
    QSettings settings;
    settings.beginGroup("QGC_MAVLINK_PROTOCOL");
    settings.setValue("VERSION_CHECK_ENABLED", m_enable_version_check);
    settings.setValue("GCS_SYSTEM_ID", systemId);
    // Parameter interface settings
}

void MAVLinkProtocol::resetMetadataForLink(LinkInterface *link)
{
    int channel = link->mavlinkChannel();
    totalReceiveCounter[channel] = 0;
    totalLossCounter[channel]    = 0;
    runningLossPercent[channel]  = 0.0f;
    for(int i = 0; i < 256; i++) {
        firstMessage[channel][i] =  1;
    }
    link->setDecodedFirstMavlinkPacket(false);
}

/**
 * This method parses all outcoming bytes and log a MAVLink packet.
 * @param link The interface to read from
 * @see LinkInterface
 **/

void MAVLinkProtocol::logSentBytes(LinkInterface* link, QByteArray b){

    uint8_t bytes_time[sizeof(quint64)];

    Q_UNUSED(link);
    if (!_logSuspendError && !_logSuspendReplay && _tempLogFile.isOpen()) {

        quint64 time = static_cast<quint64>(QDateTime::currentMSecsSinceEpoch() * 1000);

        qToBigEndian(time,bytes_time);

        b.insert(0,QByteArray((const char*)bytes_time,sizeof(bytes_time)));

        int len = b.count();

        if(_tempLogFile.write(b) != len)
        {
            // If there's an error logging data, raise an alert and stop logging.
            emit protocolStatusMessage(tr("MAVLink Protocol"), tr("MAVLink Logging failed. Could not write to file %1, logging disabled.").arg(_tempLogFile.fileName()));
            _stopLogging();
            _logSuspendError = true;
        }
    }

}

/**
 * This method parses all incoming bytes and constructs a MAVLink packet.
 * It can handle multiple links in parallel, as each link has it's own buffer/
 * parsing state machine.
 * @param link The interface to read from
 * @see LinkInterface
 **/


// 功能：MAVLink 协议解包核心函数
//  把 SerialLink/UDPLink 底层链路传来的原始字节流，通过 MAVLink 状态机逐字节解析，
//  解析出完整的 mavlink_message_t 后，进行丢包统计、日志记录、转发，最后分发给 Vehicle 处理。
//  @param link  数据来源链路
//  @param b     原始字节数组
void MAVLinkProtocol::receiveBytes(LinkInterface* link, QByteArray b)
{
    // ====== 第1步：入口校验 - 检查 link 是否还存活 ======
    // 因为 bytesReceived 信号是跨线程的，当链路已经断开后，可能还有残留信号在队列中。
    // 这里检查 link 是否还活着，如果已经销毁了就直接丢弃数据，防止访问野指针。
    SharedLinkInterfacePtr linkPtr = _linkMgr->sharedLinkInterfacePointerForLink(link, true);
    if (!linkPtr) {
        qCDebug(MAVLinkProtocolLog) << "receiveBytes: link gone!" << b.size() << " bytes arrived too late";
        return;
    }

    uint8_t mavlinkChannel = link->mavlinkChannel();    // 取该链路的 MAVLink 通道号 (0-7)

    // ====== 第2步：逐字节解析 - MAVLink 状态机 ======
    // mavlink_parse_char() 是 MAVLink 库内置的状态机，逐字节喂入，维护内部解析状态。
    // 状态机流程：等待STX(0xFE/0xFD) → 读取LEN → 读取SEQ → 读取SYSID → 读取COMPID
    //           → 读取MSGID → 读取PAYLOAD → 读取CHECKSUM(2字节CRC) → CRC校验
    // 完整一帧解析成功后返回 true，_message 中就是完整的 mavlink_message_t。
    for (int position = 0; position < b.size(); position++) {
        if (mavlink_parse_char(mavlinkChannel, static_cast<uint8_t>(b[position]), &_message, &_status)) {

            // ====== 第3步：MAVLink 版本自动检测与切换 ======
            // QGC 默认用 MAVLink V1 发送。当收到飞控发来的第一个包是 V2 格式时，
            // 自动把发送也切换到 V2，以匹配飞控的协议版本。
            // 判断依据：mavlink_get_channel_status() 返回的状态标志位
            //   IN_MAVLINK1  = 收到的包是 V1 格式
            //   OUT_MAVLINK1 = 发出的包是 V1 格式
            if (!link->decodedFirstMavlinkPacket()) {
                link->setDecodedFirstMavlinkPacket(true);
                mavlink_status_t* mavlinkStatus = mavlink_get_channel_status(mavlinkChannel);
                if (!(mavlinkStatus->flags & MAVLINK_STATUS_FLAG_IN_MAVLINK1) && (mavlinkStatus->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1)) {
                    qCDebug(MAVLinkProtocolLog) << "Switching outbound to mavlink 2.0 due to incoming mavlink 2.0 packet:" << mavlinkStatus << mavlinkChannel << mavlinkStatus->flags;
                    mavlinkStatus->flags &= ~MAVLINK_STATUS_FLAG_OUT_MAVLINK1;
                    // Set all links to v2
                    setVersion(200);
                }
            }

            // ====== 第4步：丢包率统计 ======
            // MAVLink 每个消息带有 seq 字段（0-255循环），通过比较连续两条消息的
            // seq 是否连续，就能精确统计丢包数。
            // lastIndex[sysid][compid] 记录每个飞控组件上次收到的 seq 号
            uint8_t lastSeq = lastIndex[_message.sysid][_message.compid];
            uint8_t expectedSeq = lastSeq + 1;      // 期望的下一个 seq 号
            totalReceiveCounter[mavlinkChannel]++;  // 接收计数器 +1

            // 首次收到该飞控/组件的消息，直接以当前 seq 为基准
            if(firstMessage[_message.sysid][_message.compid]) {
                firstMessage[_message.sysid][_message.compid] = 0;
                lastSeq     = _message.seq;
                expectedSeq = _message.seq;
            }

            // seq 不连续 = 有丢包，计算丢失的包数
            if (_message.seq != expectedSeq)
            {
                int lostMessages = 0;
                //-- 处理 seq 溢出（0-255 回绕）的情况
                if(_message.seq < expectedSeq) {
                    lostMessages = (_message.seq + 255) - expectedSeq;  // 溢出回绕
                } else {
                    lostMessages = _message.seq - expectedSeq;         // 正常跳变
                }
                totalLossCounter[mavlinkChannel] += static_cast<uint64_t>(lostMessages);
            }

            // 更新该飞控/组件的最后 seq 号
            lastIndex[_message.sysid][_message.compid] = _message.seq;;

            // 计算丢包率（指数移动平均，平滑处理）
            // 公式：当前丢包率 = 本次丢包率 * 0.5 + 历史丢包率 * 0.5
            uint64_t totalSent = totalReceiveCounter[mavlinkChannel] + totalLossCounter[mavlinkChannel];
            float receiveLossPercent = static_cast<float>(static_cast<double>(totalLossCounter[mavlinkChannel]) / static_cast<double>(totalSent));
            receiveLossPercent *= 100.0f;
            receiveLossPercent = (receiveLossPercent * 0.5f) + (runningLossPercent[mavlinkChannel] * 0.5f);
            runningLossPercent[mavlinkChannel] = receiveLossPercent;

            // ====== 第5步：MAVLink 转发 ======
            // 如果开启了 MAVLink 转发，把收到的消息原封不动转发到另一条链路
            // 典型场景：将飞控数据转发给另一台 GCS 或分析软件
            bool forwardingEnabled = _app->toolbox()->settingsManager()->appSettings()->forwardMavlink()->rawValue().toBool();
            if (forwardingEnabled) {
                SharedLinkInterfacePtr forwardingLink = _linkMgr->mavlinkForwardingLink();

                if (forwardingLink) {
                    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
                    int len = mavlink_msg_to_send_buffer(buf, &_message);
                    forwardingLink->writeBytesThreadSafe((const char*)buf, len);
                }
            }

            // ====== 第6步：遥测日志记录 ======
            // 将每条消息写入 .tlog 文件，每条消息前面加 8 字节 UTC 微秒时间戳（大端序）
            // 日志文件用于后续回放分析和故障排查
            // _logSuspendError: 日志写入错误时暂停，_logSuspendReplay: 回放模式不记录
            if (!_logSuspendError && !_logSuspendReplay && _tempLogFile.isOpen()) {
                uint8_t buf[MAVLINK_MAX_PACKET_LEN+sizeof(quint64)];

                // 写入 UTC 微秒级时间戳（大端序），精度为毫秒
                quint64 time = static_cast<quint64>(QDateTime::currentMSecsSinceEpoch() * 1000);
                qToBigEndian(time, buf);

                // 将 MAVLink 消息序列化，紧跟在时间戳后面
                int len = mavlink_msg_to_send_buffer(buf + sizeof(quint64), &_message);
                len += sizeof(quint64);  // 总长度 = 时间戳(8字节) + 消息体

                // 写入日志文件：时间戳 + 消息 组合格式
                QByteArray b(reinterpret_cast<const char*>(buf), len);
                if(_tempLogFile.write(b) != len)
                {
                    // 写入失败：弹窗告警并停止日志记录
                    emit protocolStatusMessage(tr("MAVLink Protocol"), tr("MAVLink Logging failed. Could not write to file %1, logging disabled.").arg(_tempLogFile.fileName()));
                    _stopLogging();
                    _logSuspendError = true;
                }

                // 检测飞控解锁：HEARTBEAT 中的 base_mode 包含 SAFETY 标志位时表示已解锁
                // 用于触发日志保存（飞行日志与地面日志的衔接点）
                if (!_vehicleWasArmed && _message.msgid == MAVLINK_MSG_ID_HEARTBEAT) {
                    mavlink_heartbeat_t state;
                    mavlink_msg_heartbeat_decode(&_message, &state);
                    if (state.base_mode & MAV_MODE_FLAG_DECODE_POSITION_SAFETY) {
                        _vehicleWasArmed = true;
                    }
                }
            }

            // ====== 第7步：HEARTBEAT / 高延迟心跳处理 ======
            // HEARTBEAT 是飞控的"心跳包"，每秒发一次，包含飞控类型和飞行器类型。
            // 这里发射 vehicleHeartbeatInfo 信号给 MultiVehicleManager，
            // 由 MultiVehicleManager 决定是否创建新的 Vehicle 对象（新飞控发现）。
            //
            // 三种等效"心跳"消息：
            //   HEARTBEAT(0)   - 标准 MAVLink 心跳，最常见
            //   HIGH_LATENCY    - 高延迟链路心跳（卫星/超远距离数传），不含 autopilot/type 信息
            //   HIGH_LATENCY2   - 高延迟链路心跳 v2，包含 autopilot/type 信息
            if (_message.msgid == MAVLINK_MSG_ID_HEARTBEAT) {
                _startLogging();  // 开始日志记录（首次收到心跳时启动日志文件）
                mavlink_heartbeat_t heartbeat;
                mavlink_msg_heartbeat_decode(&_message, &heartbeat);
                emit vehicleHeartbeatInfo(link, _message.sysid, _message.compid, heartbeat.autopilot, heartbeat.type);
            } else if (_message.msgid == MAVLINK_MSG_ID_HIGH_LATENCY) {
                _startLogging();
                mavlink_high_latency_t highLatency;
                mavlink_msg_high_latency_decode(&_message, &highLatency);
                // HIGH_LATENCY 不包含 autopilot 和 type 字段，使用 GENERIC 作为最安全的默认值
                emit vehicleHeartbeatInfo(link, _message.sysid, _message.compid, MAV_AUTOPILOT_GENERIC, MAV_TYPE_GENERIC);
            } else if (_message.msgid == MAVLINK_MSG_ID_HIGH_LATENCY2) {
                _startLogging();
                mavlink_high_latency2_t highLatency2;
                mavlink_msg_high_latency2_decode(&_message, &highLatency2);
                emit vehicleHeartbeatInfo(link, _message.sysid, _message.compid, highLatency2.autopilot, highLatency2.type);
            }

#if 0
            // 已废弃的 SiK Radio MAVLink 版本检测代码。
            // 鉴于 SiK Radio 固件当前的状态，下面的代码无法正常工作。
            // ArduPilot 的 SiK Radio 固件始终以 MAVLink V1 格式发送 RADIO_STATUS，
            // 即使飞控本身在用 MAVLink V2，导致无法通过此方法检测。
            // 因此这段代码被 #if 0 禁用。

            // Detect if we are talking to an old radio not supporting v2
            mavlink_status_t* mavlinkStatus = mavlink_get_channel_status(mavlinkChannel);
            if (_message.msgid == MAVLINK_MSG_ID_RADIO_STATUS && _radio_version_mismatch_count != -1) {
                if ((mavlinkStatus->flags & MAVLINK_STATUS_FLAG_IN_MAVLINK1)
                && !(mavlinkStatus->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1)) {
                    _radio_version_mismatch_count++;
                }
            }

            if (_radio_version_mismatch_count == 5) {
                // Warn the user if the radio continues to send v1 while the link uses v2
                emit protocolStatusMessage(tr("MAVLink Protocol"), tr("Detected radio still using MAVLink v1.0 on a link with MAVLink v2.0 enabled. Please upgrade the radio firmware."));
                // Set to flag warning already shown
                _radio_version_mismatch_count = -1;
                // Flick link back to v1
                qDebug() << "Switching outbound to mavlink 1.0 due to incoming mavlink 1.0 packet:" << mavlinkStatus << mavlinkChannel << mavlinkStatus->flags;
                mavlinkStatus->flags |= MAVLINK_STATUS_FLAG_OUT_MAVLINK1;
            }
#endif

            // ====== 第8步：定期发射链路状态信号 ======
            // 每 32 个包发射一次，供 UI 显示链路质量（丢包率、收发计数等）
            // (totalReceiveCounter & 0x1F) == 0 等价于 totalReceiveCounter % 32 == 0
            if ((totalReceiveCounter[mavlinkChannel] & 0x1F) == 0) {
                emit mavlinkMessageStatus(_message.sysid, totalSent, totalReceiveCounter[mavlinkChannel], totalLossCounter[mavlinkChannel], receiveLossPercent);
            }

            // ====== 第9步：发射消息给 Vehicle 对象 ======
            // 将解析好的 mavlink_message_t 通过信号发送给所有 Vehicle 对象。
            // 虽然在 C++ 层面直接传递整个结构体（255-261字节）有些低效，
            // 但对于地面站 PC 性能来说不是问题，且保证了跨线程的重入安全性。
            emit messageReceived(link, _message);

            // ====== 第10步：安全检查 ======
            // 消息处理回调中可能关闭了链路（比如用户断开了连接），
            // 如果 linkPtr 的唯一引用就是当前函数，说明链路已被销毁，
            // 立即退出循环，防止访问已释放的内存。
            if (1 == linkPtr.use_count()) {
                break;
            }

            // ====== 第11步：重置解析状态 ======
            // 清零 _status 和 _message，为下一个 MAVLink 帧的解析做好准备
            memset(&_status,  0, sizeof(_status));
            memset(&_message, 0, sizeof(_message));
        }
    }
}

/**
 * @return The name of this protocol
 **/
QString MAVLinkProtocol::getName()
{
    return tr("MAVLink protocol");
}

/** @return System id of this application */
int MAVLinkProtocol::getSystemId() const
{
    return systemId;
}

void MAVLinkProtocol::setSystemId(int id)
{
    systemId = id;
}

/** @return Component id of this application */
int MAVLinkProtocol::getComponentId()
{
    return MAV_COMP_ID_MISSIONPLANNER;
}

void MAVLinkProtocol::enableVersionCheck(bool enabled)
{
    m_enable_version_check = enabled;
    emit versionCheckChanged(enabled);
}

void MAVLinkProtocol::_vehicleCountChanged(void)
{
    int count = _multiVehicleManager->vehicles()->count();
    if (count == 0) {
        // Last vehicle is gone, close out logging
        _stopLogging();
        _radio_version_mismatch_count = 0;
    }
}

/// @brief Closes the log file if it is open
bool MAVLinkProtocol::_closeLogFile(void)
{
    if (_tempLogFile.isOpen()) {
        if (_tempLogFile.size() == 0) {
            // Don't save zero byte files
            _tempLogFile.remove();
            return false;
        } else {
            _tempLogFile.flush();
            _tempLogFile.close();
            return true;
        }
    }
    return false;
}

void MAVLinkProtocol::_startLogging(void)
{
    //-- Are we supposed to write logs?
    if (qgcApp()->runningUnitTests()) {
        return;
    }
    AppSettings* appSettings = _app->toolbox()->settingsManager()->appSettings();
    if(appSettings->disableAllPersistence()->rawValue().toBool()) {
        return;
    }
#ifdef __mobile__
    //-- Mobile build don't write to /tmp unless told to do so
    if (!appSettings->telemetrySave()->rawValue().toBool()) {
        return;
    }
#endif
    //-- Log is always written to a temp file. If later the user decides they want
    //   it, it's all there for them.
    if (!_tempLogFile.isOpen()) {
        if (!_logSuspendReplay) {
            if (!_tempLogFile.open()) {
                emit protocolStatusMessage(tr("MAVLink Protocol"), tr("Opening Flight Data file for writing failed. "
                                                                      "Unable to write to %1. Please choose a different file location.").arg(_tempLogFile.fileName()));
                _closeLogFile();
                _logSuspendError = true;
                return;
            }

            qCDebug(MAVLinkProtocolLog) << "Temp log" << _tempLogFile.fileName();
            emit checkTelemetrySavePath();

            _logSuspendError = false;
        }
    }
}

void MAVLinkProtocol::_stopLogging(void)
{
    if (_tempLogFile.isOpen()) {
        if (_closeLogFile()) {
            if ((_vehicleWasArmed || _app->toolbox()->settingsManager()->appSettings()->telemetrySaveNotArmed()->rawValue().toBool()) &&
                _app->toolbox()->settingsManager()->appSettings()->telemetrySave()->rawValue().toBool() &&
                !_app->toolbox()->settingsManager()->appSettings()->disableAllPersistence()->rawValue().toBool()) {
                emit saveTelemetryLog(_tempLogFile.fileName());
            } else {
                QFile::remove(_tempLogFile.fileName());
            }
        }
    }
    _vehicleWasArmed = false;
}

/// @brief Checks the temp directory for log files which may have been left there.
///         This could happen if QGC crashes without the temp log file being saved.
///         Give the user an option to save these orphaned files.
void MAVLinkProtocol::checkForLostLogFiles(void)
{
    QDir tempDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation));

    QString filter(QString("*.%1").arg(_logFileExtension));
    QFileInfoList fileInfoList = tempDir.entryInfoList(QStringList(filter), QDir::Files);
    //qDebug() << "Orphaned log file count" << fileInfoList.count();

    for(const QFileInfo& fileInfo: fileInfoList) {
        //qDebug() << "Orphaned log file" << fileInfo.filePath();
        if (fileInfo.size() == 0) {
            // Delete all zero length files
            QFile::remove(fileInfo.filePath());
            continue;
        }
        emit saveTelemetryLog(fileInfo.filePath());
    }
}

void MAVLinkProtocol::suspendLogForReplay(bool suspend)
{
    _logSuspendReplay = suspend;
}

void MAVLinkProtocol::deleteTempLogFiles(void)
{
    QDir tempDir(QStandardPaths::writableLocation(QStandardPaths::TempLocation));

    QString filter(QString("*.%1").arg(_logFileExtension));
    QFileInfoList fileInfoList = tempDir.entryInfoList(QStringList(filter), QDir::Files);

    for (const QFileInfo& fileInfo: fileInfoList) {
        QFile::remove(fileInfo.filePath());
    }
}