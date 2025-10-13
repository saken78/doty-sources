import QtQuick
import qs.config
import qs.modules.theme

Item {
     id: root
     property real amplitudeMultiplier: 0.5
     property real frequency: 6
     property color color: Colors.primaryFixed
     property real lineWidth: 4
     property real fullLength: width
     property real speed: 2.4 // unidades de fase por segundo

     Canvas {
         id: wavyCanvas
         anchors.fill: parent
         visible: Config.performance.wavyLine
         renderStrategy: Canvas.Cooperative
         renderTarget: Canvas.FramebufferObject
         antialiasing: true

         property real phase: 0
         property alias amplitudeMultiplier: root.amplitudeMultiplier
         property alias frequency: root.frequency
         property alias color: root.color
         property alias lineWidth: root.lineWidth
         property alias fullLength: root.fullLength
         property alias speed: root.speed

         onWidthChanged: requestPaint()
         onHeightChanged: requestPaint()

         Component.onCompleted: {
             animationTimer.start();
             requestPaint();
         }

         Timer {
             id: animationTimer
             interval: 50 // ~20 FPS for better performance
             running: Config.performance.wavyLine
             repeat: true
             onTriggered: {
                 // Calcula el incremento de fase basado en la velocidad y el intervalo
                 var deltaTime = interval / 1000.0; // en segundos
                 wavyCanvas.phase += root.speed * deltaTime;
                 wavyCanvas.requestPaint();
             }
         }

         onPaint: {
             if (width <= 0 || height <= 0)
                 return;

             var ctx = getContext("2d");
             ctx.save();
             ctx.clearRect(0, 0, width, height);

             // Cache invariants for this paint call
             var amplitude = root.lineWidth * root.amplitudeMultiplier;
             var frequency = root.frequency;
             var centerY = height / 2;
             var numSegments = Math.max(200, Math.min(500, width / 4)); // Adaptive segments for quality/performance
             var step = (width - root.lineWidth) / numSegments;

             ctx.strokeStyle = root.color;
             ctx.lineWidth = root.lineWidth;
             ctx.lineCap = "round";
             ctx.lineJoin = "round";
             ctx.beginPath();

             for (var i = 0; i <= numSegments; i++) {
                 var x = root.lineWidth / 2 + i * step;
                 var waveY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * x / root.fullLength + wavyCanvas.phase);
                 if (i === 0)
                     ctx.moveTo(x, waveY);
                 else
                     ctx.lineTo(x, waveY);
             }
             ctx.stroke();
             ctx.restore();
         }
     }

     Rectangle {
         id: simpleRect
         anchors.verticalCenter: parent.verticalCenter
         width: parent.width
         height: 4
         visible: !Config.performance.wavyLine
         color: root.color
         radius: 2
     }

     function requestPaint() {
         if (Config.performance.wavyLine) {
             wavyCanvas.requestPaint();
         }
     }
 }
