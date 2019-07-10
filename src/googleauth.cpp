#include <QOAuthHttpServerReplyHandler>
#include <QDesktopServices>

#include "googleauth.h"

GoogleAuth::GoogleAuth() {
    isGranted = false;
    token = "";

    auto replyHandler = new QOAuthHttpServerReplyHandler(8080, this);
    google.setReplyHandler(replyHandler);

    google.setAuthorizationUrl(QUrl(AUTH_URI));
    google.setAccessTokenUrl(QUrl(AUTH_TOKEN_URI));

    google.setClientIdentifier(CLIENT_ID);
    google.setClientIdentifierSharedKey(CLIENT_SEC);

    google.setScope("email");

    connect(&google, &QOAuth2AuthorizationCodeFlow::authorizeWithBrowser, &QDesktopServices::openUrl);
    connect(&google, &QOAuth2AuthorizationCodeFlow::statusChanged, this, &GoogleAuth::authStatusChanged);
    connect(&google, &QOAuth2AuthorizationCodeFlow::granted, this, &GoogleAuth::granted);
}

void GoogleAuth::doAuth() {

    qDebug() << "Start auth";
    google.grant();

}

void GoogleAuth::authStatusChanged(QAbstractOAuth::Status status) {

    QString s;
    if (status == QAbstractOAuth::Status::Granted)
        s = "granted";

    if (status == QAbstractOAuth::Status::TemporaryCredentialsReceived) {
        s = "temp credentials";
    }
    qDebug() << s;
}

void GoogleAuth::granted() {

    QString gtoken = google.token();
    qDebug() << gtoken;
    isGranted = true;
    token = gtoken;
}

