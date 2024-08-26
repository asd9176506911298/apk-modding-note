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

function showHeroInfo2(){
    var so = Module.findBaseAddress('libil2cpp.so')
    //ShowHeroInfo
    var addr = so.add(0x266A840)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            console.log('ShowHeroInfo: ' + args[3]);
            args[3] = ptr(1);
        },
        onLeave: function (retval){}
    })
    //ShowHeroHpInfo
    var addr = so.add(0x29C9610)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            args[1] = ptr(1);
        },
        onLeave: function (retval){}
    })
    //ShowSkillStateInfo
    var addr = so.add(0x29C9748)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            args[1] = ptr(1);
        },
        onLeave: function (retval){}
    })
    //ShowReviveTimeInfo
    var addr = so.add(0x29C987C)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
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

function testmap(){
    var so = Module.findBaseAddress('libil2cpp.so')
    console.log(so.add(0x2D3E804).readByteArray(0x20));
    var addr = so.add(0x2D3E804);
    Memory.patchCode(addr,10, code=>{
        const cw = new Arm64Writer(code, { pc: addr });
        cw.putInstruction(0x52800036)
        cw.flush()
    })
}

function run(){
    Java.perform(()=>{
        console.log('script perform')
        // showHeroInfo2();
        // test();
        // Aimbot();
        // showHeroInfo();
        // MapHack();
        // testmap();
        ESP();
        
    })
};



function ESP(){
    var so = Module.findBaseAddress('libil2cpp.so')

    var IsHero = new NativeFunction(so.add(0x2BEBA5C), 'bool', ['pointer'])
    

    //Update


    //worldtoScreen test
    var addr = so.add(0x2C348E4)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            // console.log(`x:${x} y:${y} z:${z}`)
        },
        onLeave: function (retval){
            console.log(retval.readPointer().readByteArray(0x40))
            // retval.replace(0x1);
            // return retval;
        }
    })
}

function test(){
    var so = Module.findBaseAddress('libil2cpp.so')
        

    //show history
    var addr = so.add(0x21AF064)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter');
        },
        onLeave: function (retval){
            // console.log(retval)
            retval.replace(0x1);
            return retval;
        }
    })
    //aimbot
    var addr = so.add(0x26CAC48)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0].add(0x78).readInt());
            // if(args[0].add(0x78).readInt() == 2){ //slot 2
            //     args[1] = ptr(99999);
            // }
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })
    //position
    var addr = so.add(0x2E3D968)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0].add(0x16C).readU8());
            // console.log(so.add(0x79B22A0).readPointer().add(0xB8).readByteArray(0x50));
            //isLocal
            if(args[0].add(0x16C).readU8()){
                //position
                // console.log('x: ' + args[0].add(0x154).readInt())
                // console.log('y: ' + args[0].add(0x158).readInt())
                // console.log('z: ' + args[0].add(0x15C).readInt())
                
                //forward
                // console.log('x: ' + args[0].add(0x148).readInt())
                // console.log('y: ' + args[0].add(0x14C).readInt())
                // console.log('z: ' + args[0].add(0x150).readInt())
                // args[0].add(0x154).writeInt(args[0].add(0x154).readInt()+500);
            }
            // args[0].add(0x3B3).writeU8(0x1);
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })
    //camera
    var addr = so.add(0x27E0A08)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0]);
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })
    //WorldToScreen 0x3E0A60C
    var addr = so.add(0x1EECDEC)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[1]);
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    //width
    var addr = so.add(0x4453678)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('width');
        },
        onLeave: function (retval){
            console.log('width:' + retval.toInt32())
            // retval.replace(0x1);
            // return retval;
        }
    })

    //height
    var addr = so.add(0x44536AC)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('height');
        },
        onLeave: function (retval){
            console.log('height:' + retval.toInt32())
            // retval.replace(0x1);
            // return retval;
        }
    })

    //height
    var addr = so.add(0x4453B08)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('DPI');
        },
        onLeave: function (retval){
            // console.log('height:' + retval.toInt32())
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

// setImmediate(run)
