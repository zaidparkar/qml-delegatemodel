import QtQuick
import ModelClass

Window {
    id: applicationWindow
    visible: true

    Rectangle {
        id: root
        anchors{fill:parent; margins: 10}

        ContactClass {
            id: mymodel
        }

        DelegateModel {
            id: visualModel
            model: mymodel
            delegate: ContactListDelegate {}
        }

        ListView {
            id: fullView
            anchors{fill: parent}
            clip: true
            spacing: 15

            model: visualModel.parts.fullList

            Component {
                id: sectionDelegate
                Rectangle {
                    width: 5
                    height: 18
                    color: "transparent"

                    Text {
                        font.pixelSize: 12
                        text: section.toUpperCase()
                    }
                }
            }

            section.property: "name"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: sectionDelegate
        }

        ListView {
            id: contactView
            anchors{fill: parent}
            visible: false
            interactive: false
            clip: true

            model: visualModel.parts.contact

            onCurrentIndexChanged: {
                contactView.positionViewAtIndex(currentIndex, ListView.Contain)
            }
        }


        state: "inFullList"
        states: [
            State {
                name: "inContact"
                when: root.state == "inContact"
                PropertyChanges { target: fullView; interactive: false; visible: false }
                PropertyChanges { target: contactView; visible: true }
            }
        ]
    }

    Component.onCompleted: {
        mymodel.getContacts()

        contentItem.Keys.released.connect(function(event) {
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if(root.state == "inContact") {
                    root.state = "inFullList"
                }
            }
        })
    }
}


