
function run(){
    Java.perform(()=>{
        console.log('script perform')
        test();
        
    })
};



function test(){
    var so = Module.findBaseAddress('libil2cpp.so')

    //DebugMgr
    var addr = so.add(0xA9F284)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log('onEnter')
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    var glo = so.add(0x5B4F6A8)
    console.log(glo.readPointer())

}


function awaitForCondition(callback) {
    var i = setInterval(function () {
      var addr = Module.findBaseAddress('libil2cpp.so');
        console.log("Address found:", addr);
        if (addr) {
            clearInterval(i);
            callback(+addr);
        }
    }, 0);
}


Java.perform(function () {
    awaitForCondition(function (base) {
  // do something
        run();
    })
})