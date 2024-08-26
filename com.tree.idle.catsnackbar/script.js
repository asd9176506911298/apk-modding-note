var so;

function run(){
    so = Module.findBaseAddress('libil2cpp.so')

    var SetCheatWindow = new NativeFunction(so.add(0x249487C), 'void', ['pointer', 'bool'])
    var AllUIShow = new NativeFunction(so.add(0x2B04A04), 'void', ['pointer'])
    var AllUIHide = new NativeFunction(so.add(0x2B04818), 'void', ['pointer'])
    
    var SetActive = new NativeFunction(so.add(0x2543A5C), 'void', ['pointer', 'bool', 'int'])
    var SetActive2 = new NativeFunction(so.add(0x2B02AC0), 'void', ['pointer', 'bool', 'int'])
    var SetActive3 = new NativeFunction(so.add(0xB1BCC4), 'void', ['pointer', 'bool', 'int'])
    

    var StartTutorial = new NativeFunction(so.add(0x2A5AE68), 'void', ['pointer'])
    var OnClickCheat = new NativeFunction(so.add(0x8CC208), 'void', ['pointer'])

    var HideAll = new NativeFunction(so.add(0x8C54E4), 'void', ['pointer'])
    var ScreenTopOn = new NativeFunction(so.add(0x8CC504), 'void', ['pointer', 'bool'])

    var OnEnable = new NativeFunction(so.add(0x2A60D98), 'void', ['pointer'])

    var Complete = new NativeFunction(so.add(0xA1EDC8), 'void', ['pointer'])
    
    var ShowCheatBtn = new NativeFunction(so.add(0x8C59AC), 'void', ['pointer', 'bool'])
    
    var CheatGoToGameStage = new NativeFunction(so.add(0x2752E38), 'void', ['pointer', 'int'])
    
    var Unlock = new NativeFunction(so.add(0xF4BED4), 'void', ['pointer'])
    
    console.log('Script Perform')

    var addr = so.add(0x2B07C74)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log('onEnter: ' + args[0].toInt32())
        },
        onLeave: function(retval){
            return retval
        }
    })
    var addr = so.add(0x108AED8)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log('onEnter')
            // console.log(args[3])
            // console.log('rewardType: ' + args[1].toInt32())
            // console.log('rewardIdx: ' + args[2].toInt32())
            // console.log('rewardCnt: ' + args[3].toInt32())
            // console.log('hudRefresh: ' + args[4])
        },
        onLeave: function(retval){
            return retval
        }
    })

    var addr = so.add(0x1078604)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log('onEnter')
        },
        onLeave: function(retval){
            return retval
        }
    })

    var addr = so.add(0x255FE80)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log(args[0].readPointer().readByteArray(0x30))
            // console.log(args[1])
            // console.log(args[2])
            // console.log(args[3])
            // console.log(args[4])
            // args[2] = ptr(2147483647)
            // args[4] = ptr(0)
        },
        onLeave: function(retval){
            return retval
        }
    })

    var addr = so.add(0x2C011A4)
    Interceptor.attach(addr, {
        onEnter: function(args){
        },
        onLeave: function(retval){
            retval.replace(999999)
            return retval
        }
    })
    
    //sub
    var addr = so.add(0x255FE80)
    Interceptor.attach(addr, {
        onEnter: function(args){
            console.log('onEnter')
            console.log('sub: ' + args[4].toInt32()) //add amount
            // args[2] = ptr(2147483647)
            // args[4] = ptr(0)

            console.log(args[0])
            console.log(args[1])
            console.log(args[2]) //curCurrency
            console.log(args[3])
            console.log(args[4].toInt32()) //sub amount
            
        },
        onLeave: function(retval){
            return retval
        }
    })

    //add
    var addr = so.add(0x255F924)
    Interceptor.attach(addr, {
        onEnter: function(args){
            console.log('onEnter')
            console.log('add: ' + args[4].toInt32()) //add amount
            // args[1] = ptr("0x000000ff")
            // args[4] = ptr(0)

            console.log(args[0])
            console.log(args[1]) //curCurrency
            console.log(args[2]) 
            console.log(args[3])
            console.log(args[4]) //add amount
        },
        onLeave: function(retval){
            return retval
        }
    })
    
}

setTimeout(run, 1000)