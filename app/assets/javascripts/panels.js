

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
    $('.bouton-' + category_string).click(function(){
      $(".panel-results > div > .panel").hide();
      $('.panel-' + category_string).toggle(500);
    });
 }

var a = ["mentions-legales","cookies", "cgvu", "data-privacy"]

a.forEach(function(element) {
  panelShow(element);
});
