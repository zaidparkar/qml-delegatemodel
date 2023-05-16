#include "modelclass.h"
#include <QJniObject>
#include <QGuiApplication>
#include <QDebug>

ModelClass* current = nullptr;

ModelClass::ModelClass(QObject *parent)
    : QAbstractListModel(parent)
{
    current = this;
}

int ModelClass::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return contactList.size();
}


QVariant ModelClass::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
    case NameRole:
        return QVariant(contactList.at(index.row()).getName());
    case NumberRole:
        return QVariant(contactList.at(index.row()).getNumber());
    }

    return QVariant();
}

bool ModelClass::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(index.isValid()) {
        if (data(index, role) != value) {
            switch (role) {
            case NameRole:
                contactList[index.row()].setName(value.toString());
            case NumberRole:
                contactList[index.row()].setNumber(value.toString());
            }

            emit dataChanged(index, index, {role});
            return true;
        }
    }
    return false;
}

QHash<int, QByteArray> ModelClass::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames [NameRole] = "name";
    roleNames [NumberRole] = "number";
    return roleNames;
}

void ModelClass::populate(QStringList data)
{
    if(contactList.isEmpty()) {

        beginResetModel();
        for(QString &contact: data) {
            QStringList nameAndNumber = contact.split(" : ");
            QString name = nameAndNumber.at(0);
            QString number = nameAndNumber.at(1);
            Contact currentContact = Contact(name,number);
            contactList.append(currentContact);
        }
        endResetModel();
    }
}

void ModelClass::getContacts()
{
    QJniObject javaClass = QNativeInterface::QAndroidApplication::context();
    javaClass.callMethod<void>("callGetContacts","()V");
}




#ifdef __cplusplus
extern "C" {
#endif
JNIEXPORT void JNICALL
Java_com_example_contactsPicker_MainActivity_getContactsJNI(JNIEnv *env, jobject obj, jobject jlist) {

    QStringList qstrList;

    jclass listClass = env->GetObjectClass(jlist);
    jmethodID sizeMethod = env->GetMethodID(listClass, "size", "()I");
    jmethodID getMethod = env->GetMethodID(listClass, "get", "(I)Ljava/lang/Object;");
    jint size = env->CallIntMethod(jlist, sizeMethod);

    for (jint i = 0; i < size; i++) {
        jstring jstr = (jstring) env->CallObjectMethod(jlist, getMethod, i);
        const char *cstr = env->GetStringUTFChars(jstr, nullptr);
        QString qstr = QString::fromUtf8(cstr);
        env->ReleaseStringUTFChars(jstr, cstr);
        qstrList.append(qstr);
    }

    current->populate(qstrList);

}

#ifdef __cplusplus
}
#endif
