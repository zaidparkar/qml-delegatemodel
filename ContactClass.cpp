#include <QAbstractListModel>

class Contact{

private:
    QString id;
    QString name;
    QString number;

public:
    Contact(const QString &id, const QString &name, const QString &number) {
        this->id = id;
        this->name = name;
        this->number = number;
    }

    QString getName() const{
        return name;
    };

    void setName(const QString &newName){
        name = newName;
    }

    QString getNumber() const {
        return number;
    }

    void setNumber(const QString &newNumber) {
        number = newNumber;
    }

    QString getId() const {
        return id;
    }

    void setId(const QString &newId) {
        id = newId;
    }
};
