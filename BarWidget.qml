import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "maen.openclaw"
  ipcTarget: "maen.openclaw"
  manageIpc: true

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property bool isGatewayActive: false
  property bool isProcessing: false

  function checkStatus() {
    if (statusCheckProc.running) return
    statusCheckProc.running = true
  }

  function startGateway() {
    isProcessing = true
    Quickshell.execDetached(["systemctl", "--user", "start", "openclaw-gateway.service"])
    quickCheckTimer.start()
  }

  function stopGateway() {
    isProcessing = true
    Quickshell.execDetached(["systemctl", "--user", "stop", "openclaw-gateway.service"])
    quickCheckTimer.start()
  }

  function openDashboard() {
    Quickshell.execDetached(["omarchy-launch-openclaw"])
    root.close()
  }

  function openTui() {
    Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "openclaw tui"])
    root.close()
  }

  Process {
    id: statusCheckProc
    command: ["systemctl", "--user", "is-active", "openclaw-gateway.service"]
    running: false
    onExited: function(exitCode) {
      root.isGatewayActive = (exitCode === 0)
      root.isProcessing = false
    }
  }

  Timer {
    id: pollTimer
    interval: root.opened ? 3000 : 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.checkStatus()
  }

  Timer {
    id: quickCheckTimer
    interval: 1200
    repeat: false
    onTriggered: root.checkStatus()
  }

  onOpenedChanged: {
    if (root.opened) root.checkStatus()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // ---------- Top Bar Button ----------
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.iconSlot
    tooltipText: root.isGatewayActive ? "OpenClaw Gateway: Running (380MB cap)" : "OpenClaw Gateway: Stopped (Click to toggle)"
    onPressed: root.toggle()

    iconComponent: Component {
      Item {
        anchors.fill: parent

        Image {
          anchors.centerIn: parent
          width: Style.space(16)
          height: Style.space(16)
          source: Qt.resolvedUrl("assets/openclaw.png")
          fillMode: Image.PreserveAspectFit
          opacity: root.isGatewayActive ? 1.0 : 0.4
          Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
          visible: root.isGatewayActive
          width: Style.space(5)
          height: Style.space(5)
          radius: Style.space(3)
          color: "#22c55e"
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.rightMargin: Style.space(1)
          anchors.bottomMargin: Style.space(1)
        }
      }
    }
  }

  // ---------- Popup Panel Card ----------
  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: Component {
      // 100% Solid Opaque Background Card
      Rectangle {
        id: cardContent
        implicitWidth: Style.space(340)
        implicitHeight: mainColumn.implicitHeight + Style.space(28)
        color: "#0d1117"
        radius: Style.cornerRadius
        border.width: 1
        border.color: "#30363d"

        Column {
          id: mainColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: Style.space(14)
          spacing: Style.space(12)

          // ---------- Header Row ----------
          Row {
            width: parent.width
            spacing: Style.space(12)

            Image {
              width: Style.space(36)
              height: Style.space(36)
              source: Qt.resolvedUrl("assets/openclaw.png")
              fillMode: Image.PreserveAspectFit
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(4)

              Text {
                textFormat: Text.PlainText
                text: "OpenClaw Gateway"
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
                color: "#f0f6fc"
              }

              // Status Badge Pill
              Rectangle {
                height: Style.space(22)
                width: statusRow.implicitWidth + Style.space(16)
                radius: Style.space(11)
                color: root.isGatewayActive ? "#052e16" : "#161b22"
                border.width: 1
                border.color: root.isGatewayActive ? "#16a34a" : "#30363d"

                Row {
                  id: statusRow
                  anchors.centerIn: parent
                  spacing: Style.space(6)

                  Rectangle {
                    width: Style.space(7)
                    height: Style.space(7)
                    radius: Style.space(4)
                    color: root.isGatewayActive ? "#22c55e" : "#8b949e"
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Text {
                    textFormat: Text.PlainText
                    text: root.isGatewayActive ? "Online · 380 MB Cap" : "Offline · 0 MB RAM"
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    color: root.isGatewayActive ? "#4ade80" : "#8b949e"
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }
              }
            }

            Item {
              width: Math.max(0, parent.width - x - closeBtn.width)
              height: 1
            }

            PanelActionButton {
              id: closeBtn
              iconText: "󰅖"
              tooltipText: "Close"
              foreground: "#8b949e"
              hoverColor: "#f0f6fc"
              anchors.verticalCenter: parent.verticalCenter
              onClicked: root.close()
            }
          }

          // Divider
          Rectangle {
            width: parent.width
            height: 1
            color: "#21262d"
          }

          // ---------- Details Grid Card ----------
          Rectangle {
            width: parent.width
            height: Style.space(38)
            radius: Style.cornerRadius
            color: "#161b22"
            border.width: 1
            border.color: "#30363d"

            Row {
              anchors.centerIn: parent
              spacing: Style.space(20)

              Row {
                spacing: Style.space(6)
                Text {
                  textFormat: Text.PlainText
                  text: "Port:"
                  color: "#8b949e"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }
                Text {
                  textFormat: Text.PlainText
                  text: "18789"
                  color: "#f0f6fc"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }

              Rectangle {
                width: 1
                height: Style.space(14)
                color: "#30363d"
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                spacing: Style.space(6)
                Text {
                  textFormat: Text.PlainText
                  text: "Autostart:"
                  color: "#8b949e"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }
                Text {
                  textFormat: Text.PlainText
                  text: "Off (On-Demand)"
                  color: "#f0f6fc"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }
            }
          }

          // ---------- Start Gateway Button (When Stopped) ----------
          Rectangle {
            visible: !root.isGatewayActive
            width: parent.width
            height: Style.space(42)
            radius: Style.cornerRadius
            color: startMouse.containsMouse ? "#22c55e" : "#16a34a"
            border.width: 1
            border.color: "#4ade80"

            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: "▶"
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: root.isProcessing ? "Starting Gateway..." : "Start Gateway"
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: startMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.startGateway()
            }
          }

          // ---------- Stop Gateway Button (When Running) ----------
          Rectangle {
            visible: root.isGatewayActive
            width: parent.width
            height: Style.space(40)
            radius: Style.cornerRadius
            color: stopMouse.containsMouse ? "#dc2626" : "#b91c1c"
            border.width: 1
            border.color: "#ef4444"

            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                text: "■"
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                textFormat: Text.PlainText
                text: root.isProcessing ? "Stopping Gateway..." : "Stop Gateway"
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: stopMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.stopGateway()
            }
          }

          // ---------- Secondary Actions (When Running) ----------
          Column {
            visible: root.isGatewayActive
            width: parent.width
            spacing: Style.space(8)

            // Web Dashboard Button
            Rectangle {
              width: parent.width
              height: Style.space(36)
              radius: Style.cornerRadius
              color: webMouse.containsMouse ? "#21262d" : "#161b22"
              border.width: 1
              border.color: "#30363d"

              Behavior on color { ColorAnimation { duration: 120 } }

              Row {
                anchors.centerIn: parent
                spacing: Style.space(8)

                Text {
                  textFormat: Text.PlainText
                  text: "󰖟"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  color: "#f0f6fc"
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: "Open Web Dashboard"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  color: "#f0f6fc"
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              MouseArea {
                id: webMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openDashboard()
              }
            }

            // Terminal TUI Button
            Rectangle {
              width: parent.width
              height: Style.space(36)
              radius: Style.cornerRadius
              color: tuiMouse.containsMouse ? "#21262d" : "#161b22"
              border.width: 1
              border.color: "#30363d"

              Behavior on color { ColorAnimation { duration: 120 } }

              Row {
                anchors.centerIn: parent
                spacing: Style.space(8)

                Text {
                  textFormat: Text.PlainText
                  text: "󰆍"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  color: "#f0f6fc"
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  textFormat: Text.PlainText
                  text: "Open Terminal TUI"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  color: "#f0f6fc"
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              MouseArea {
                id: tuiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openTui()
              }
            }
          }

          // Divider
          Rectangle {
            width: parent.width
            height: 1
            color: "#21262d"
          }

          // ---------- Footer ----------
          Text {
            width: parent.width
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            text: "On-demand execution · Zero background RAM"
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: "#6e7681"
          }
        }
      }
    }
  }
}
