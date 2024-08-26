function hook(){
    console.log('start');
    var so = Module.findBaseAddress('libil2cpp.so')
    //SetVisible
    var addr = so.add(0x1EED0E0)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log('onEnter: ' + args[2]);
            // args[2] = ptr(1);
        },
        onLeave: function(retval){}
    })

    //test
    var addr = so.add(0x20F63A0)
    Interceptor.attach(addr, {
        onEnter: function(args){
            console.log('onEnter: ');
        },
        onLeave: function(retval){
            console.log('retval: ' + retval);
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
function makeToast(string) {
    Java.perform(function () { 
        var context = Java.use('android.app.ActivityThread').currentApplication().getApplicationContext();
    
        Java.scheduleOnMainThread(function() {
                var toast = Java.use("android.widget.Toast");
                toast.makeText(Java.use("android.app.ActivityThread").currentApplication().getApplicationContext(), Java.use("java.lang.String").$new(string), 1).show();
        });
    });
}

var il2cpp = null;

Java.perform(function () {
    awaitForCondition(function (base) {
        il2cpp = ptr(base);
  // do something
        makeToast('Modded by Yuki.kaco');
        hook();
    })
})

