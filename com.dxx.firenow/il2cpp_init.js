function awaitForCondition(callback) {
    var i = setInterval(function () {
      var addr = Module.findBaseAddress('libunity.so');
        console.log("Address found:", addr);
        if (addr) {
            clearInterval(i);
            callback(+addr);
        }
    }, 0);
}

function test(){
    var il2cpp = Module.findBaseAddress('libil2cpp.so')
    var unity = Module.findBaseAddress('libunity.so')
    
    var address = (unity.add(0x10B2F4C).readPointer() - il2cpp).toString(16);
    console.log(`il2cpp_init:${address}`)
    
}

var il2cpp = null;

Java.perform(function () {
    awaitForCondition(function (base) {
        il2cpp = ptr(base);
        // do something
        test()
    })
})