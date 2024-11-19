import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

Window {
    id: mainWindow
    width: squareSize * rowCount
    height: width
    visible: true
    title: qsTr("Langton's Ant(s)")
    color: "darkGreen"

    property int rowCount: 151
    property int squareSize: 5
    property int squareSpacing: 2
    property int steps: 0
    readonly property bool mortal: false
    property int count: 0

    GridLayout {
        anchors.centerIn: parent
        rows: rowCount
        rowSpacing: squareSpacing
        columns: rowCount
        columnSpacing: squareSpacing
        Repeater {
            id: yard
            model: Math.pow(rowCount, 2)
            signal kill(int index)

            Rectangle {
                property bool isStepped: false
                property int step: 0
                property int depletion: 1
                property bool depleted: false
                onIsSteppedChanged: {
                    if (mortal) {
                        step++
                        if (step == 10 * depletion && !depleted )
                        {
                            depletion++
                            depleted = true
                            antComponent.createObject(mainWindow, { index: index });
                        } else if (step == 10 * depletion) {
                            depletion++
                            depleted = false
                            yard.kill(index)
                        }
                    }
                }

                Layout.preferredWidth: squareSize - squareSpacing
                Layout.preferredHeight: squareSize - squareSpacing
                color: isStepped ? "green" : "darkGreen"
                MouseArea {
                    anchors.fill: parent
                    onClicked: antComponent.createObject(mainWindow, { index: index });
                }
            }
        }
    }

    Component {
        id: antComponent
        Ant {
            id: ant
            width: squareSize
            height: squareSize
            direction: 3
            index: Math.floor(Math.pow(rowCount, 2)/2)
            speed: tickTock.interval
            onIndexChanged: {
                if (!!yard.itemAt(ant.index))
                    walk(yard.itemAt(ant.index).x, yard.itemAt(ant.index).y)
            }

            Component.onCompleted: count++
            Component.onDestruction: count--

            Connections {
                target: tickTock
                function onTriggered() {
                    ant.direction = (ant.direction + (yard.itemAt(ant.index).isStepped ? 3 : 1)) % 4
                    yard.itemAt(ant.index).isStepped = !yard.itemAt(ant.index).isStepped
                    steps++

                    var newIndex = ant.index
                    switch(ant.direction) {
                    case 0: {
                        newIndex-=rowCount
                        break;
                    }
                    case 1: {
                        newIndex++
                        break;
                    }
                    case 2: {
                        newIndex+=rowCount
                        break;
                    }
                    case 3: {
                        newIndex--
                        break;
                    }
                    default:{}
                    }

                    if (newIndex > (Math.pow(rowCount,2) - 1) || newIndex < 0)
                        ant.index = Math.floor(Math.pow(rowCount, 2)/2)
                    else
                        ant.index = newIndex
                }
            }
            Connections {
                target: yard
                function onKill(index) {
                    if (ant.index === index)
                        ant.destroy()
                }
            }
        }
    }

    Timer {
        id: tickTock
        interval: 100
        repeat: true
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "transparent"
        visible: !tickTock.running
        height: implicitHeight
        width: implicitWidth

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            id: playBtn
            anchors.centerIn: parent
            width: 200
            height: 100
            radius: 10
            color: "darkGray"

            Text {
                anchors.centerIn: parent
                text: "PLAY"
                color: "white"
                font {
                    pixelSize: 30
                    bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: tickTock.start()

            }
        }
    }

    Text {
        id: antCounter
        anchors {
            top: mainWindow.top
            topMargin: 20
            left: mainWindow.left
            leftMargin: 20
        }
        height: contentHeight
        width: contentWidth
        font.pixelSize: 20
        color: "white"
        opacity: .5
        enabled: false
        text: count + (count == 1 ? " Ant" : " Ants")
    }
    Text {
        anchors {
            top: antCounter.bottom
            left: mainWindow.left
            leftMargin: 20
        }
        height: contentHeight
        width: contentWidth
        font.pixelSize: 20
        color: "white"
        opacity: .5
        enabled: false
        text: steps + (steps == 1 ? " Step" : " Steps")
    }
}
