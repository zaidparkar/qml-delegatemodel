import QtQuick
import ModelClass


Window {
    id: root
    width: 640
    height: 480
    visible: true


    ListView {
        id: list
        width: parent.width
        height: 350
        anchors{topMargin: 5;}
        clip: true
        spacing: 4

        Component {
            id: tasksDelegate
            Rectangle {
                width: root.width
                border{width: 1}
                height: 40
                Row {
                    spacing: 50
                    anchors.centerIn: parent

                    Text {
                        text: model.name
                        font.pixelSize: 18
                    }

                    Text {
                        text: model.number
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        ModelClass {
            id: mymodel
        }

        model: mymodel

        delegate: tasksDelegate
    }

    Rectangle {
        id: getButton
        width: 200
        height: 60
        anchors{top: list.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 10}
        border {
            width: 1
            color: "black"
        }
        Text {
            anchors{centerIn: parent}
            text: qsTr("Get Contacts")
        }
        MouseArea  {
            anchors.fill: parent
            onClicked: {
                console.log("Clicked")
                mymodel.getContacts();
            }
        }
    }
}


