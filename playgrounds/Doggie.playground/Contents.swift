//: Playground - noun: a place where people can play

import Cocoa
import Doggie



let arrayA = [1, 2, 3, 4]
let arrayB = [5, 6, 7, 8]
let concated = arrayA.concat(arrayB)

Array(concated)  // [1, 2, 3, 4, 5, 6, 7, 8]



let task = SDTask { () -> Int in
    sleep(2)
    return 5
}

let task2 = task.then { a -> Int in
    sleep(2)
    return a + 1
}

task.wait(deadline: .now() + 1).then {
    $0
}

task.wait(deadline: .now() + 2).then {
    $0
}

task.wait(until: .now() + 1)

task.result   // 5
task2.result  // 6

task.wait(until: .now() + 1)


let path = try SDPath(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")



let marker: SDMarker = "<p>\n    <h1>{{% header %}}</h1>\n{{# ! bool #}}    This line never shown.<br />{{# bool #}}{{# bool #}}    This line will shown.<br />{{# bool #}}{{#loop#}}\n    {{%loop%}}<br />{{#loop#}}{{#list#}}\n    {{%item%}}<br />{{#list#}}\n</p>"

print(marker.render([
    
    "header": "This is a header",
    "bool": true,
    "loop": 3,
    "list": [
        ["item": "apple"],
        ["item": "banana"],
        ["item": "orange"]
    ]
    
    ]))

