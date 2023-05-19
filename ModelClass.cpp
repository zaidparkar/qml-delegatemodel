#include "ModelClass.h"
#include <QJniObject>
#include <QGuiApplication>
#include <QDebug>
#include <QJsonDocument>


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
    case IDRole:
        return QVariant(contactList.at(index.row()).getId());
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
            case IDRole:
                contactList[index.row()].setId(value.toString());
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
    roleNames [IDRole] = "id";
    roleNames [NameRole] = "name";
    roleNames [NumberRole] = "number";
    return roleNames;
}

void ModelClass::populate(std::list<Contact> data)
{
    beginResetModel();
    if(contactList.isEmpty()) {
        for(Contact &contact: data) {
            contactList.append(contact);
        }      
    }
    endResetModel();
}

void ModelClass::removeContact(Contact toDelete) {
    int index = 0;
    for(auto iter=contactList.begin(); iter!=contactList.end();iter++,index++) {
        if(iter->getName() == toDelete.getName()) {
            if(iter->getNumber() == toDelete.getNumber()) {
                beginRemoveRows(QModelIndex(), index, index);
                contactList.removeAt(index);
                endRemoveRows();
                break;
            }
        }
    }
}

void ModelClass::getContacts()
{
    QJniObject javaClass = QNativeInterface::QAndroidApplication::context();
    javaClass.callMethod<void>("getContacts","()V");
}

JNIEnv* getJNIEnv()
{
    JNIEnv* env = nullptr;
    JavaVM* jvm = QJniEnvironment::javaVM();
    jint result = jvm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6);
    if (result == JNI_OK)
        return env;

    JavaVMAttachArgs attachArgs;
    attachArgs.version = JNI_VERSION_1_6;
    attachArgs.name = "NativeThread";
    attachArgs.group = nullptr;

    result = jvm->AttachCurrentThread(&env, &attachArgs);
    if (result == JNI_OK)
        return env;

    return nullptr;
}

void ModelClass::deleteContact(QString id)
{
    JNIEnv* env = getJNIEnv();
    jstring jID = env->NewStringUTF(id.toUtf8().constData());

    QJniObject javaClass = QNativeInterface::QAndroidApplication::context();
    javaClass.callMethod<void>("deleteContactFromPhone","(Ljava/lang/String;)V",jID);
}

void ModelClass::modifyContact(QString id, QString newName, QString newNumber)
{
    JNIEnv* env = getJNIEnv();
    jstring jID = env->NewStringUTF(id.toUtf8().constData());
    jstring jnewName = env->NewStringUTF(newName.toUtf8().constData());
    jstring jnewNumber = env->NewStringUTF(newNumber.toUtf8().constData());

    QJniObject javaClass = QNativeInterface::QAndroidApplication::context();
    javaClass.callMethod<void>("updateContacts","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",jID,jnewName,jnewNumber);
}


#ifdef __cplusplus
extern "C" {
#endif
JNIEXPORT void JNICALL
Java_com_example_contactsPicker_MainActivity_getContactsJNI(JNIEnv *env, jobject obj, jstring jsonContacts) {

    QVariantList qJsonDoc = QJsonDocument::fromJson(env->GetStringUTFChars(jsonContacts,0)).toVariant().toList();

    std::list<Contact> contacts;

    QVariantList::iterator iter;
    for(iter = qJsonDoc.begin(); iter != qJsonDoc.end(); iter++)
    {
        QVariantMap contactMap = (*iter).toMap();
        QString id = contactMap["id"].toString();
        QString name = contactMap["name"].toString();
        QString number = contactMap["number"].toString();
        contacts.push_back(Contact(id,name, number));
    }
    current->contactList.clear();
    current->populate(contacts);
}

#ifdef __cplusplus
}
#endif
