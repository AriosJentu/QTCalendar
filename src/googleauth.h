#ifndef GOOGLEAUTH_H
#define GOOGLEAUTH_H

#include <QOAuth2AuthorizationCodeFlow>
#include <QAbstractOAuth>

//#include "OAuth/o2google.h"
//#include "OAuth/o1requestor.h"

#define CLIENT_ID "nothing"
#define CLIENT_SEC "nothing"
#define AUTH_URI "https://accounts.google.com/o/oauth2/auth"
#define AUTH_TOKEN_URI "https://oauth2.googleapis.com/token"

/*class GoogleAuth: public QObject {

    Q_OBJECT

    public:
        explicit GoogleAuth(QObject* parent = nullptr);

    signals:

        void extraTokensReady(const QVariantMap& extraTokens);
        void linkingFailed();
        void linkingSuccessed();

    public slots:

        void doOAuth(O2::GrantFlow grantFlowType);
        void validateToken();

    private slots:

        void onLinkedChanged();
        void onLinkingSucceeded();
        void onOpenBrowser(const QUrl &url);
        void onCloseBrowser();
        //void onFinished();

    private:

        O2Google* google;
};*/

class GoogleAuth: public QObject {

    Q_OBJECT

    QOAuth2AuthorizationCodeFlow google;
    bool isGranted;
    QString token;

    public:

        Q_INVOKABLE void doAuth();
        Q_INVOKABLE bool isAutorized() {return isGranted;}
        Q_INVOKABLE QString getToken() {return token;}

        GoogleAuth();

    public slots:

        void authStatusChanged(QAbstractOAuth::Status status);
        void granted();
};


#endif // GOOGLEAUTH_H
