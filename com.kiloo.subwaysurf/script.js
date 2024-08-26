var so;



function run(){
    so = Module.findBaseAddress('libil2cpp.so')

    var test = new NativeFunction(so.add(0x9539BC), 'pointer', ['pointer'])
    var test1 = new NativeFunction(so.add(0x9538D0), 'pointer', ['pointer','float', 'float'])
    var Jump = new NativeFunction(so.add(0x953440), 'pointer', ['pointer'])
    var JumpAdvanced = new NativeFunction(so.add(0x953120), 'pointer', ['pointer', 'float', 'bool', 'bool'])

    console.log('Script Perform')

    var addr = so.add(0x9516BC)
    Interceptor.attach(addr, {
        onEnter: function(args){
            // console.log(args[0].add(0xC8).readU8())
            // args[0].add(0xAC).writeFloat(200) //200
            // args[0].add(0xA8).writeFloat(25) //25
            args[0].add(0x80).writeFloat(100) //20
            
            JumpAdvanced(args[0], 20, 1, 0)
            // test(args[0])
            // args[0].add(0x150).writeFloat(45) //
        },
        onLeave: function(retval){
            return retval
        }
    })

    var addr = so.add(0x6227E8)
    Interceptor.attach(addr, {
        onEnter: function(args){
            
            // console.log('Jump')
        },
        onLeave: function(retval){
            return retval
        }
    })

}

setTimeout(run, 800)