//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
//= require justgage
//= require panels
function jauge(elementClass) {
  var gaugeElement = document.querySelector(elementClass);
  if (gaugeElement) {
    var g1;
    g1 = new JustGage({
      id: "g1",
      value: gaugeElement.dataset.analysisScore,
      valueFontColor: "black",
      labelFontColor: "black",
      valueFontFamily: "Panamera-Regular",
      min: 0,
      max: 100,
      donut: true,
      gaugeWidthScale: 0.6,
      counter: true,
      hideInnerShadow: true,
      levelColors: [
        "#e33100",
        "#ff5c00",
        "#91bd09"
        ],
    });
  }
}
document.addEventListener("DOMContentLoaded", function(event) {
  jauge(".gauge");
});

//
//   var gaugeElement = document.querySelector(".gauge");

//   console.log('Hello hal')
//   if (gaugeElement) {
//     var g1;
//     document.addEventListener("DOMContentLoaded", function(event) {
//       g1 = new JustGage({
//         id: "g1",
//         value: gaugeElement.dataset.analysisScore,
//         valueFontColor: "black",
//         labelFontColor: "black",
//         valueFontFamily: "Raleway",
//         min: 0,
//         max: 100,
//         donut: true,
//         gaugeWidthScale: 0.6,
//         counter: true,
//         hideInnerShadow: true,
//         levelColors: [
//           "#e33100",
//           "#ff5c00",
//           "#91bd09"
//           ],
//       });
//     });
//   }
// }
