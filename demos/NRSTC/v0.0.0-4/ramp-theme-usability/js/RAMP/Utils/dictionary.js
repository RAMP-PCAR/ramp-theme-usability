/*! ramp-theme-usability 25-05-2015 18:15:59 : v. 5.4.0-8 
 * 
 * RAMP GIS viewer - Elk; Sample of an implementation of RAMP with Usability Theme 
 **/
define(["dojo/_base/lang"],function(a){"use strict";return{forEachEntry:function(b,c,d,e){e&&(c=a.hitch(e,c));var f=[];for(var g in b)b.hasOwnProperty(g)&&f.push(g);d&&f.sort(d),f.forEach(function(a){c(a,b[a])})},find:function(a,b,c){var d=[];for(var e in a)a.hasOwnProperty(e)&&d.push(e);c&&d.sort(c);var f=-1;return d.forEach(function(c,d){-1===f&&b(c,a[c])&&(f=d)}),f},filter:function(a,b){var c={};return this.forEachEntry(a,function(a,d){b(a,d)&&(c[a]=d)}),c},length:function(a){return Object.keys(a).length},isEmpty:function(a){return 0===this.length(a)},clone:function(a){var b={};return this.forEachEntry(a,function(a,c){b[a]=c}),b},arrayToMap:function(a,b){var c={};return a.forEach(function(d){c[b(a)]=d}),c},zip:function(a,b){if(a.length!==b.length)throw"Array lengths differ";var c={};return a.forEach(function(a,d){c[a]=b[d]}),c}}});