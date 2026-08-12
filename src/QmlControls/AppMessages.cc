/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/



// Allows QGlobalStatic to work on this translation unit
#define _LOG_CTOR_ACCESS_ public

#include "AppMessages.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "AppSettings.h"

#include <QStringListModel>
#include <QtConcurrent>
#include <QTextStream>

Q_GLOBAL_STATIC(AppLogModel, debug_model)

static QtMessageHandler old_handler;

static void msgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    //日志等级：QtDebugMsg, QtWarningMsg, QtCriticalMsg, QtFatalMsg, QtInfoMsg
    const char symbols[] = { 'D', 'E', '!', 'X', 'I' };
    QString output = QString("[%1] at %2:%3 - \"%4\"").arg(symbols[type]).arg(context.file).arg(context.line).arg(msg);

    // Avoid recursion---防止 Qt Quick 日志 → log() → UI 更新 → 更多日志 → 死循环
    if (!QString(context.category).startsWith("qt.quick")) {
        debug_model->log(output);
    }

    if (old_handler != nullptr) {
        old_handler(type, context, msg);        //调用旧日志处理器，保留格式
    }
    if( type == QtFatalMsg ) abort();       //致命错误直接终止，abort()立即终止程序，不执行析构
}

//安装自定义日志处理器
void AppMessages::installHandler()
{
    old_handler = qInstallMessageHandler(msgHandler);       //返回值：旧的日志处理器（保存起来）

    // Force creation of debug model on installing thread
    Q_UNUSED(*debug_model);         //强制创建 debug_model，确保日志模型在安装线程创建
}

//获取日志模型
AppLogModel *AppMessages::getModel()
{
    return debug_model;
}

//AppLogModel 构造函数（线程安全关键）
AppLogModel::AppLogModel() : QStringListModel()
{
#ifdef __mobile__           //移动端 UI 线程限制更严格
    Qt::ConnectionType contype = Qt::QueuedConnection;      //跨线程信号槽（异步）
#else
    Qt::ConnectionType contype = Qt::AutoConnection;        //同线程直调，跨线程队列
#endif
    //信号 → 槽连接：自定义信号--实际写日志的槽--根据平台选择连接方式
    connect(this, &AppLogModel::emitLog, this, &AppLogModel::threadsafeLog, contype);
}

void AppLogModel::writeMessages(const QString dest_file)
{
    const QString writebuffer(stringList().join('\n').append('\n'));

    QtConcurrent::run([dest_file, writebuffer] {
        emit debug_model->writeStarted();
        bool success = false;
        QFile file(dest_file);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << writebuffer;
            success = out.status() == QTextStream::Ok;
        } else {
            qWarning() << "AppLogModel::writeMessages write failed:" << file.errorString();
        }
        emit debug_model->writeFinished(success);
    });
}

void AppLogModel::log(const QString message)
{
    emit debug_model->emitLog(message);
}

void AppLogModel::threadsafeLog(const QString message)
{
    const int line = rowCount();
    insertRows(line, 1);
    setData(index(line), message, Qt::DisplayRole);

    if (qgcApp() && qgcApp()->logOutput() && _logFile.fileName().isEmpty()) {
        qDebug() << _logFile.fileName().isEmpty() << qgcApp()->logOutput();
        QGCToolbox* toolbox = qgcApp()->toolbox();
        // Be careful of toolbox not being open yet
        if (toolbox) {
            QString saveDirPath = qgcApp()->toolbox()->settingsManager()->appSettings()->crashSavePath();
            QDir saveDir(saveDirPath);
            QString saveFilePath = saveDir.absoluteFilePath(QStringLiteral("QGCConsole.log"));

            _logFile.setFileName(saveFilePath);
            if (!_logFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
                qgcApp()->showAppMessage(tr("Open console log output file failed %1 : %2").arg(_logFile.fileName()).arg(_logFile.errorString()));
            }
        }
    }

    if (_logFile.isOpen()) {
        QTextStream out(&_logFile);
        out << message << "\n";
        _logFile.flush();
    }
}
