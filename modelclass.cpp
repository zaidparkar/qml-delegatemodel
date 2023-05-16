#include "modelclass.h"
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

void ModelClass::removeContact(std::list<Contact> data) {
    for(Contact &contact : data) {
        QList<Contact>::iterator iter = std::find(contactList.begin(), contactList.end(), contact);
        const auto index = std::distance(contactList.begin(), iter);
        if(index < contactList.size()){
            beginRemoveRows(QModelIndex(), index, index);
            contactList.removeAt(index);
            endRemoveRows();
        }
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
Java_com_example_contactsPicker_MainActivity_getContactsJNI(JNIEnv *env, jobject obj, jstring jsonContacts) {

    QVariantList qJsonDoc = QJsonDocument::fromJson(env->GetStringUTFChars(jsonContacts,0)).toVariant().toList();

    std::list<Contact> contacts;

    QVariantList::iterator iter;
    for(iter = qJsonDoc.begin(); iter != qJsonDoc.end(); iter++)
    {
        QVariantMap contactMap = (*iter).toMap();
        QString name = contactMap["name"].toString();
        QString number = contactMap["number"].toString();
        contacts.push_back(Contact(name, number));
    }
    current->populate(contacts);
}

#ifdef __cplusplus
}
#endif
