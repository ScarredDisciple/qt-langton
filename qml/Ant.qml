import QtQuick

Rectangle {
    color:"transparent"

    property int speed: 1000
    property int direction: 0
    property int index: 0

    function walk(newX, newY) {
            x = newX
            y = newY
    }

    Image {
        source: "qrc:ant.png"
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        rotation: direction*90
    }

    Behavior on x { XAnimator { duration: speed }}
    Behavior on y { YAnimator { duration: speed }}
}
