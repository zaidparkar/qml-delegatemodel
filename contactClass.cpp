#include <QAbstractListModel>

class Contact{

private:
    QString name;
    QString number;

public:
    Contact(const QString &name, const QString &number) {
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
};
