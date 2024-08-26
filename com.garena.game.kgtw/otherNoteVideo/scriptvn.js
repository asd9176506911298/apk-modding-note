function showHeroInfo(){
    var so = Module.findBaseAddress('libil2cpp.so')

    //ShowHeroInfo
    var addr = so.add(0x266A840)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log("onEnter:Hero " + args[3]);
            args[3] = ptr(1);
        },
        onLeave: function (retval){}
    })
    //ShowHeroCampFrame
    // var addr = so.add(0x29C9494)
    // Interceptor.attach(addr, {
    //     onEnter: function (args) {
    //         console.log("onEnter: ");
    //         // args[1] = ptr(1);
    //     },
    //     onLeave: function (retval){}
    // })

    //ShowHeroDeadMask
    // var addr = so.add(0x29C9574)
    // Interceptor.attach(addr, {
    //     onEnter: function (args) {
    //         console.log("onEnter: ");
    //         // args[1] = ptr(0);
    //     },
    //     onLeave: function (retval){}
    // })

    //ShowHeroHpInfo
    var addr = so.add(0x29C9610)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log("onEnter: ");
            args[1] = ptr(1);
        },
        onLeave: function (retval){}
    })

    //ShowReviveTimeInfo
    var addr = so.add(0x29C987C)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log("onEnter: ");
            args[1] = ptr(1);
        },
        onLeave: function (retval){}
    })

    //ShowSkillStateInfo
    var addr = so.add(0x29C9748)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log("onEnter: ");
            args[1] = ptr(1);
        },
        onLeave: function (retval){}
    })
}

function MapHack(){
    var so = Module.findBaseAddress('libil2cpp.so')
    //Map Hack
    var addr = so.add(0x2D3E7E4)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('Map' + args[2]);
            args[2] = ptr(1);
        },
        onLeave: function (retval){}
    })
}

function Aimbot(){
    var so = Module.findBaseAddress('libil2cpp.so')
    //GetTargetImpl
    var addr = so.add(0x26CAC48)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter' + args[0]);
            // args[1] = ptr(999999);
        },
        onLeave: function (retval){}
    })
}
function run(){
    Java.perform(()=>{
        var so = Module.findBaseAddress('libil2cpp.so')
        console.log("Script perform")



        //test
        var addr = so.add(0xB5B9C4)
        Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log('test ' + args[0].readCString()); 

            // args[1] = ptr(999999);
        },
        onLeave: function (retval){
            console.log('retval: ' + retval);
        }
        })

        console.log(so.add(0x605BEF4).readPointer().add(0x100).readS32())
        console.log(so.add(0x605BEF4).readPointer().add(0x104).readS32())
        var a = so.add(0x605BEF4).readPointer().add(0x100).readS32()
        var b = so.add(0x605BEF4).readPointer().add(0x104).readS32()
        var total = a + b

        console.log(total)

        console.log(Module.load('libil2cpp.so').size)
        // console.log(so.add(0x605BEF4).readPointer().add(0x108).readS32())
        // console.log(so.add(0x605BEF4).readPointer().add(0x10C).readS32())
        
        // Aimbot();
        // showHeroInfo();
        // MapHack();
        
    })
};

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

function init(){
    Java.perform(function () {
        awaitForCondition(function (base) {
      // do something
            run();
        })
    })
}


// setImmediate(run)
setTimeout(init, 100);