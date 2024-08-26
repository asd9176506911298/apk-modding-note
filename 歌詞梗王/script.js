
function run(){
    Java.perform(()=>{
        console.log('script perform')
        test();
        
    })
};



function test(){
    var so = Module.findBaseAddress('libil2cpp.so')

    // Namespace: BPGame
    // public class AdManager : Singleton<AdManager>
    // public void Init() { }
    //adManager
    var addr = so.add(0xAC4F28)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            args[0].add(0x18).writeU8(1)
            args[0].add(0x19).writeU8(1)

        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })


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