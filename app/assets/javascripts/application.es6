//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
//= require justgage

var gaugeElement = document.querySelector(".gauge");

if (gaugeElement) {
  var g1;
  document.addEventListener("DOMContentLoaded", function(event) {
    g1 = new JustGage({
      id: "g1",
      value: gaugeElement.dataset.analysisScore,
      valueFontColor: "black",
      labelFontColor: "black",
      valueFontFamily: "Raleway",
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
  });
}


// $(".bouton-mentions-legales").click(function(){
//     $(".panel-mentions-legales").toggle(500);
// });


// $(".bouton-cookies").click(function(){
//     $(".panel-cookies").toggle(500);
// });

// $(".bouton-cgvu").click(function(){
//     $(".panel-cgvu").toggle(500);
// });


// $(".bouton-dataprivacy").click(function(){
//     $(".panel-dataprivacy").toggle(500);
// });


 function panelShow(category_string)
 {
    $(`.bouton-${category_string}`).click(function(){
      $(`.panel-${category_string}`).toggle(500);
      // $(".panel-results > .panel").attr('style', 'display: none');
    });
 }

var a = ["mentions-legales","cookies", "cgvu", "data-privacy"]

a.forEach((element) => {
  panelShow(element);
});
