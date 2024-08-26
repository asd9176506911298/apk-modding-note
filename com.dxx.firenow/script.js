
function run(){
    Java.perform(()=>{
        console.log('script perform')
        test();
        
    })
};



function test(){
    var so = Module.findBaseAddress('libil2cpp.so')

    var SetEnable = new NativeFunction(so.add(0xff38ac), 'void', ['pointer','bool'])
    var get_IsGray = new NativeFunction(so.add(0xff2e4c), 'bool', ['pointer'])
    var SetActive = new NativeFunction(so.add(0x2e35fc4), 'void', ['pointer', 'bool'])

    var GetRemoteCommonConfig = new NativeFunction(so.add(0x1533070), 'pointer', [])
    var GetLocalCommonConfig = new NativeFunction(so.add(0x153313c), 'pointer', [])
    var get_HTTP_SERVER_URL = new NativeFunction(so.add(0xc27300), 'pointer', [])
    var get_CDN_URL = new NativeFunction(so.add(0xc275e4), 'pointer', [])
    var get_FeedBack_Url = new NativeFunction(so.add(0xc27b08), 'pointer', [])
    var get_ServerUrl = new NativeFunction(so.add(0x4ba2330), 'pointer', [])
    var GetDebugModeEnable = new NativeFunction(so.add(0x150c014), 'pointer', [])
    var get_GetMaxChapter = new NativeFunction(so.add(0x150c120), 'pointer', [])
    
    var get_value = new NativeFunction(so.add(0x1af4350), 'pointer', ['pointer'])
    var set_value = new NativeFunction(so.add(0x1af4358), 'pointer', ['pointer','bool'])
    
    // console.log(GetRemoteCommonConfig().add(0xC).readUtf16String())
    // console.log(GetLocalCommonConfig().add(0xC).readUtf16String())
    // console.log(get_HTTP_SERVER_URL().add(0xC).readUtf16String())
    // console.log(get_CDN_URL().add(0xC).readUtf16String())
    // console.log(get_FeedBack_Url().add(0xC).readUtf16String())
    // console.log(get_ServerUrl().add(0xC).readUtf16String())
    // console.log(GetDebugModeEnable().add(0xC).readUtf16String())
    // console.log(get_GetMaxChapter())

    //get_IsDebugMode
    var addr = so.add(0x11e694c)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    //DebugMgr
    var addr = so.add(0x1511b94)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0].add(0xC).readUtf16String())
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    //SurvivorsDebugPanel
    var addr = so.add(0x23f5354)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0].add(0x48).readPointer().add(0x54).readU8())
            // SetEnable(args[0].add(0x48), 0)
            // console.log(get_IsGray(args[0].add(0x48).readPointer()))
            
            // console.log(args[0].add(0x78))
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    //SetActive
    var addr = so.add(0x2e35fc4)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter' + args[1])
            // args[1] = ptr(1)
        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    

    //OpenUI
    var addr = so.add(0x1f982d0)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter' + args[1])
            // args[1] = ptr(300)

        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    //Invincible
    var addr = so.add(0x1533070)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log(args[0].add(0xC).readUtf16String())

        },
        onLeave: function (retval){
            // console.log(retval)
            // retval.replace(0x1);
            // return retval;
        }
    })

    
    //PlayerPrefsMgr
    var addr = so.add(0x17e0a90)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')
            // console.log(get_value(args[0].add(0x1B0)))
            // set_value(args[0].add(0x1A4),1)
            // set_value(args[0].add(0x1A8),1)
            // set_value(args[0].add(0x1AC),1)
            // set_value(args[0].add(0x1B0),1)
            // console.log(get_value(args[0].add(0x1B0)))
        },
        onLeave: function (retval){
            // console.log(retval)
            // console.log(retval.add(0xC).readUtf16String())
            // retval.replace(0x10);
            // return retval;
        }
    })
    
    //Url
    var addr = so.add(0x11eb27c)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter')

        },
        onLeave: function (retval){
            // console.log(retval.add(0xC).readUtf16String())
            // retval.replace(0x1);
            // return retval;
        }
    })

    //UpdateHotfixDownloading
    var addr = so.add(0x11e9ea4)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // console.log('onEnter:' + args[0].add(0x10).readInt())
            // args[0].add(0x10).writeInt(3)
            

        },
        onLeave: function (retval){
            // console.log(retval.add(0xC).readUtf16String())
            // retval.replace(0x1);
            // return retval;
        }
    })

    //UpdateHotfixDownloading
    var addr = so.add(0x1a70020)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            // args[0].add(0x8).writeU8(1)
            // args[0].add(0x9).writeU8(1)
            // args[0].add(0xA).writeU8(1)
            // args[0].add(0xB).writeU8(1)
            // args[0].add(0xC).writeU8(1)
            // args[0].add(0xD).writeU8(1)
            // args[0].add(0x39).writeU8(1)
            // args[0].add(0x54).writeU8(1)

            

        },
        onLeave: function (retval){
            // console.log(retval.add(0xC).readUtf16String())
            // console.log(retval.readByteArray(0x40))
            // retval.replace(0x0);
            // return retval;
        }
    })

    //UpdateHotfixDownloading
    var addr = so.add(0x2548d04)
    Interceptor.attach(addr, {
        onEnter: function (args) {
            console.log('onEnter')
        },
        onLeave: function (retval){
            // console.log(retval.add(0xC).readUtf16String())
            // console.log(retval.readByteArray(0x40))
            console.log(retval)
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