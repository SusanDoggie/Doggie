//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let path1 = try Shape(code: "M89.519,116.084c-11.976,31.189-38.601,41.458-53.065,25.444c-14.116-15.628-4.32-41.719,23.573-54.181c19.079-8.524,51.003-9.777,72.727,0.537c25.568,12.139,32.399,35.87,13.692,48.669c-15.201,10.401-30.093-2.211-39.784-19.466c-15.021-26.75-12.634-54.875,0.255-79.138c9.319-17.546,24.098-29.044,43.142-13.428c24.929,20.441,0.69,41.354-26.336,50.344c-18.069,6.01-36.383,11.018-63.603-5.588C39.18,56.502,22.589,37.476,35.094,23.825c13.085-14.286,36.227-11.396,49.794,10.99C99.513,58.943,99.079,91.187,89.519,116.084z")

let region = ShapeRegion(path1, winding: .nonZero)
let ellipse = Shape.Ellipse(path1.boundary)
let region2 = ShapeRegion(ellipse, winding: .nonZero)

path1 + ellipse

region.union(region2)

region.intersection(region2)
region.subtracting(region2)
region2.subtracting(region)
region.symmetricDifference(region2)

let path2 = try Shape(code: "M141.102,150.83c100,90.476,85.715-36.055-4.762,76.871s112.763-105.442,36.994-76.871S141.102,150.83,141.102,150.83z")

let region3 = ShapeRegion(path2, winding: .nonZero)
let ellipse2 = Shape.Ellipse(path2.boundary)
let region4 = ShapeRegion(ellipse2, winding: .nonZero)

path2 + ellipse2

region3.union(region4)
region3.intersection(region4)
region3.subtracting(region4)
region4.subtracting(region3)
region3.symmetricDifference(region4)

ShapeRegion(Shape.Ellipse(x: 100, y: 100, rx: 100, ry: 100) + Shape.Ellipse(x: 110, y: 100, rx: 100, ry: 100) + Shape.Ellipse(x: 120, y: 100, rx: 100, ry: 100), winding: .nonZero)
ShapeRegion(Shape.Ellipse(x: 100, y: 100, rx: 100, ry: 100) + Shape.Ellipse(x: 110, y: 100, rx: 100, ry: 100) + Shape.Ellipse(x: 120, y: 100, rx: 100, ry: 100), winding: .evenOdd)

var square = Shape.Rectangle(x: 0, y: 0, width: 100, height: 100)
var square2 = Shape.Rectangle(x:110, y: 0, width: 50, height: 100)
let circle = Shape.Ellipse(x: 100, y: 100, rx: 100, ry: 100)

square.transform = SDTransform.rotate(0.1)

let r_square = ShapeRegion(square, winding: .nonZero).union(ShapeRegion(square2, winding: .nonZero))
let r_circle = ShapeRegion(circle, winding: .nonZero)

r_square.shape + r_circle.shape

r_square.union(r_circle)
r_square.intersection(r_circle)
r_square.subtracting(r_circle)
r_circle.subtracting(r_square)
r_square.symmetricDifference(r_circle)

var square3 = Shape.Rectangle(x: 0, y: 0, width: 100, height: 100)
var square4 = Shape.Rectangle(x:50, y: 10, width: 50, height: 80)

square3 + square4

ShapeRegion(square3, winding: .nonZero).union(ShapeRegion(square4, winding: .nonZero))
ShapeRegion(square3, winding: .nonZero).intersection(ShapeRegion(square4, winding: .nonZero))
ShapeRegion(square3, winding: .nonZero).subtracting(ShapeRegion(square4, winding: .nonZero))
ShapeRegion(square4, winding: .nonZero).subtracting(ShapeRegion(square3, winding: .nonZero))
ShapeRegion(square3, winding: .nonZero).symmetricDifference(ShapeRegion(square4, winding: .nonZero))

let circle2 = Shape.Ellipse(x: 100, y: 100, rx: 100, ry: 100)
let circle3 = Shape.Ellipse(x: 149, y: 100, rx: 80, ry: 80)
let circle4 = ShapeRegion(circle2, winding: .nonZero).union(ShapeRegion(circle3, winding: .nonZero))
ShapeRegion(circle2, winding: .nonZero).intersection(ShapeRegion(circle3, winding: .nonZero))

circle4.shape + circle3

circle4.union(ShapeRegion(circle3, winding: .nonZero))
circle4.intersection(ShapeRegion(circle3, winding: .nonZero))
circle4.subtracting(ShapeRegion(circle3, winding: .nonZero))
ShapeRegion(circle3, winding: .nonZero).subtracting(circle4)
circle4.symmetricDifference(ShapeRegion(circle3, winding: .nonZero))

let circle5 = Shape.Ellipse(x: 50, y: 50, radius: 100)
var circle6 = Shape.Ellipse(x: 50, y: 50, radius: 70)
circle6.transform *= SDTransform.reflectX(50)
var circle7 = circle5 + circle6.identity
circle7.transform *= SDTransform.translate(x: -50, y: -50) * SDTransform.scale(1 / 3) * SDTransform.translate(x: 50, y: 50)
var circle8 = circle7.identity
circle8.transform *= SDTransform.translate(x: -50, y: -50) * SDTransform.scale(1 / 3) * SDTransform.translate(x: 50, y: 50)

circle5 + circle6.identity + circle7.identity
ShapeRegion(circle5 + circle6.identity + circle7.identity, winding: .nonZero)
circle5 + circle6.identity + circle7.identity + circle8.identity
ShapeRegion(circle5 + circle6.identity + circle7.identity + circle8.identity, winding: .nonZero)

let path3 = try Shape(code: "M-12231.558 1811.189c5.138-0.188 10.245-0.375 15.321-0.563-0.188 1.567-0.376 3.134-0.563 4.7l14.664 1.41c0.313-2.256 0.595-4.512 0.846-6.768 8.397-0.439 16.638-0.941 24.722-1.505l-0.752-10.903c-7.708 0.501-15.228 0.939-22.56 1.315 0.062-0.438 0.125-0.909 0.188-1.41 2.945-0.125 5.733-0.345 8.365-0.657 5.578-0.752 9.714-2.57 12.408-5.453 2.256-2.318 3.384-6.58 3.384-12.783v-2.444c0-2.632-0.721-5.546-2.162-8.741-2.318-4.387-6.862-7.145-13.63-8.272-1.128-0.126-2.318-0.251-3.572-0.376 0.063-0.439 0.157-0.908 0.282-1.41 6.393 0.313 12.753 0.47 19.082 0.47l1.222-11.655c-6.517 0-12.814-0.095-18.894-0.283 0.251-2.318 0.532-4.637 0.847-6.955l-10.152-1.034 1.128-5.733c-8.46-2.257-16.481-3.385-24.064-3.385h-4.042c-7.582 0-14.068 1.473-19.458 4.418-5.891 3.76-8.836 9.056-8.836 15.887 0 5.953 1.128 12.721 3.384 20.303l14.57-3.289c-2.256-5.39-3.384-10.184-3.384-14.383 0-3.446 1.315-6.016 3.948-7.707 2.443-1.566 6.518-2.351 12.22-2.351 5.765 0 12.157 0.784 19.176 2.351-0.062 0.375-0.125 0.752-0.188 1.127-8.397-0.5-16.481-1.189-24.253-2.067l-1.033 11.75c7.959 0.752 15.917 1.379 23.876 1.88-0.063 0.439-0.126 0.939-0.188 1.504h-3.478c-6.894 0.062-11.97 1.034-15.229 2.914-4.637 2.444-6.956 7.708-6.956 15.792 0 4.136 2.162 10.778 6.486 19.929l6.486-1.692c2.569 0.814 5.17 1.409 7.802 1.786-0.062 1.002-0.188 1.911-0.376 2.726-6.142 0.313-12.157 0.627-18.048 0.94l1.411 10.617v0zm33.276-24.439c0.126-1.379 0.282-2.727 0.47-4.042 1.692-0.188 3.385-0.345 5.076-0.47l-0.752-10.246c-1.064 0.125-2.067 0.219-3.008 0.281 0.062-0.877 0.156-1.785 0.282-2.726 2.318 0.564 4.042 1.599 5.17 3.103 1.128 1.816 1.692 3.76 1.692 5.828 0 2.568-0.313 4.292-0.94 5.17-1.253 1.566-3.384 2.568-6.392 3.008-0.564 0.063-1.097 0.094-1.598 0.094v0 0zm-12.784-18.048c-0.188 1.692-0.375 3.353-0.563 4.981-3.196 0.251-6.329 0.502-9.4 0.752 0.376-1.816 1.159-3.07 2.351-3.76 1.189-1.127 3.727-1.784 7.612-1.973v0 0zm-1.88 15.228c-0.125 0.814-0.219 1.661-0.282 2.539-2.256-0.377-4.48-0.973-6.674-1.787-0.062-0.125-0.125-0.219-0.188-0.281 2.444-0.126 4.825-0.283 7.144-0.471v0 0zm-38.916 21.526c6.329-1.003 11.594-2.507 15.792-4.513l-3.76-13.159c-5.389 2.256-10.653 3.886-15.792 4.888l3.76 12.784v0zm-2.913-18.048c5.953-1.003 10.935-2.476 14.945-4.418l-3.76-12.784c-5.139 2.131-10.121 3.76-14.946 4.888l3.761 12.314v0 0.094-0.094z")
ShapeRegion(path3, winding: .nonZero)

let path4 = try Shape(code: "M-984.636 742.232c-1.817-0.627-3.76-1.254-5.828-1.881l-2.726 12.032c8.021 2.757 16.794 5.107 26.32 7.05 8.084 1.566 15.071 2.35 20.962 2.35 8.586 0 16.23-1.441 22.937-4.324 5.577-2.945 8.397-6.831 8.46-11.656 0-2.507-1.566-7.019-4.7-13.536-2.632-5.514-3.948-9.023-3.948-10.527 0-3.134 0.564-4.7 1.692-4.7 4.136 0.689 7.175 1.817 9.118 3.384l3.102-12.031c-3.822-2.193-8.68-3.322-14.57-3.385-4.449 0-8.146 1.316-11.092 3.948-0.312 0.313-0.627 0.657-0.939 1.034l-0.94-3.103c-6.392 1.817-12.032 3.384-16.92 4.7 0.188-1.943 0.345-3.854 0.47-5.734l-13.912-1.598c-0.25 3.885-0.533 7.614-0.846 11.186-5.64-3.258-11.625-6.861-17.954-10.81l-6.486 10.246c4.575 3.071 9.118 5.922 13.63 8.554-4.888-0.125-9.808-0.219-14.758-0.281l-1.034 12.313c3.634 0.062 7.332 0.157 11.092 0.282-1.441 1.253-2.914 2.443-4.418 3.572l3.288 2.915v0zm46.531-22.466c0.188 1.566 0.657 3.354 1.41 5.358-5.892-0.313-11.813-0.595-17.767-0.847 0.188-3.446 0.407-6.924 0.658-10.434l2.819 9.307c4.764-1.066 9.056-2.193 12.88-3.384v0 0zm3.571 10.716c0.251 0.563 0.47 1.096 0.658 1.598 2.883 5.577 4.324 9.306 4.324 11.186 0 2.006-1.441 3.541-4.324 4.606-2.131 0.689-4.355 1.19-6.674 1.504l4.888-7.896c-2.131-1.254-4.387-2.633-6.768-4.137 2.381 0.125 4.794 0.251 7.238 0.376l0.658-7.237v0zm-8.46 19.176c-1.128 0.063-2.193 0.094-3.195 0.094-2.883 0-6.236-0.282-10.059-0.846 0.313-3.948 0.627-8.021 0.94-12.22 1.253 0.062 2.538 0.125 3.854 0.188l-3.666 5.828c4.073 2.694 8.115 5.013 12.126 6.956v0 0zm-26.978-3.478c-1.943-0.564-4.011-1.128-6.204-1.691 1.817-1.441 3.446-3.165 4.888-5.17l-3.478-3.291c1.817 0.063 3.634 0.126 5.452 0.188-0.25 3.384-0.47 6.706-0.658 9.964v0 0zm-15.98 46.06l13.818-3.008c-0.752-1.253-1.441-2.569-2.068-3.948 19.113 1.316 37.507 2.037 55.179 2.162l1.127-11.656c-20.867-0.063-41.391-0.909-61.569-2.538-1.379-3.572-2.538-7.238-3.478-10.998l-14.006 2.914c2.381 9.588 6.047 18.612 10.997 27.072v0 0zm56.024-18.424l1.034-10.434c-16.356 0-32.869-1.159-49.538-3.478l-1.128 10.622c15.479 2.193 32.023 3.29 49.632 3.29v0 0 0.094-0.094z")
ShapeRegion(path4, winding: .nonZero)

let path5 = try Shape(code: "M449.127,350.453c0-23.945,0-23.945-23.552-23.944c-24.31,0-24.31,0-24.308,24.515c0.002,17.46,13.765,39.994,24.114,39.484C436.186,389.975,449.127,368.148,449.127,350.453L449.127,350.453z")
ShapeRegion(path5, winding: .nonZero)

let path6 = try Shape(code: "M373.04799661 553.698336436c-22.032077501-4.772733832-38.597353082-24.120478798-38.890777037-47.326553627 1.089327541-3.995462061 2.404000956-7.998920095 3.956530821-12.009602804 0.205999918-0.533000079-0.849000024-1.554000041-1.475-2.619-0.158116223 0.03699363-0.315824005 0.074821663-0.473130966 0.113468502 2.670337712-8.981200469 7.863428448-16.894275668 14.764148787-22.930768611 1.011354504-0.149732972 2.021389775-0.30708912 3.029982179-0.464699892 12.901318539-2.016465671 24.670876493-7.781432267 37.285007197-11.221379185 23.707863834 3.632877031 41.882418815 23.980571567 41.882418815 48.505223134 0 14.515677757-6.366968933 27.568070406-16.479748167 36.5574563-7.026985262 0.209269556-14.053456144 0.761556317-21.077677845 1.67269975-14.783551103 1.917816958-21.66237518 3.893398609-22.521753784 9.723156432zm41.656753784-27.610156432c-5.894-9.461-4.501-24.473-17.699-25.152-12.649-0.65-18.535-5.959-21.416-16.498-1.983-7.252-5.129-5.791-9.565-2.743-10.723 7.368-17.116 32.439-11.176 43.919 3.005 5.807 8.12 7.227 13.926 6.523 14.856-1.803 29.678-3.888 45.93-6.049z")
let path7 = try Shape(code: "M414.704750394 526.088180004c-16.252 2.16-31.074 4.246-45.93 6.048-5.806 0.704-10.922-0.716-13.926-6.523-5.94-11.479 0.453-36.55 11.176-43.919 4.436-3.048 7.583-4.509 9.565 2.743 2.881 10.54 8.767 15.848 21.416 16.498 13.198 0.68 11.805 15.693 17.699 25.153z")
let region5 = ShapeRegion(path6, winding: .nonZero)
let region6 = ShapeRegion(path7, winding: .nonZero)

region5.union(region6)

