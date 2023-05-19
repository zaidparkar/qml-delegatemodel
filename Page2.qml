import QtQuick

Item {
    id: page2
//        anchors{fill: parent}
    width: root.width
    height: root.height
    visible: false
    y: root.height

    Column {
        id: allElementsPage2
        spacing: 30
        anchors{centerIn: parent}

        Rectangle{
            id: name
            width: 200
            height: 50
            border{width: 1}
            TextInput {
                id: nameTextInput
                text: currentName
                anchors{centerIn: parent}
                font{pixelSize: 18}
            }
        }

        Rectangle {
            id: number
            width: 200
            height: 50
            border{width: 1}
            TextInput {
                id: numberTextInput
                text: currentNumber
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                anchors{centerIn: parent}
                font{pixelSize: 18}
            }
        }

        Rectangle {
            width: 200
            height: 60
            anchors{topMargin: 10}
            border {
                width: 1
                color: "black"
            }
            Text {
                anchors{centerIn: parent}
                text: qsTr("Update Contact")
            }
            MouseArea  {
                anchors.fill: parent
                onClicked: {
                    mymodel.modifyContact(currentID.toString(),nameTextInput.text.toString(),numberTextInput.text.toString())
                    mymodel.getContacts()
                    root.navigateTo(page1)
                }
            }
        }

        Rectangle {
            width: 200
            height: 60
            anchors{topMargin: 10}
            border {
                width: 1
                color: "black"
            }
            Text {
                anchors{centerIn: parent}
                text: qsTr("Delete Contact")
            }
            MouseArea  {
                anchors.fill: parent
                onClicked: {
                    mymodel.deleteContact(currentID.toString())
                    mymodel.getContacts()
                    root.navigateTo(page1)
                }
            }
        }

        Rectangle {
            width: 200
            height: 60
            anchors{topMargin: 10}
            border {
                width: 1
                color: "black"
            }
            Text {
                anchors{centerIn: parent}
                text: qsTr("Go Back")
            }
            MouseArea  {
                anchors.fill: parent
                onClicked: {
                    root.navigateTo(page1)
                }
            }
        }
    }
}
