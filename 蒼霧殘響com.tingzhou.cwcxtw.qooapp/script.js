function run(){
    console.log("script perform")
    Java.perform(()=>{
        var so = Module.findBaseAddress('libil2cpp.so')
        // public class CMgrHot : MgrBase<CMgrHot>
        //     public string GetAssetUrl() { }
        //     public string GetUrl() { }
        //     public string GetManifest() { }
        //     public string GetResPath(bool isFull = False) { }
        //     public static void SetFightState(int _state) { }
        var Asserturl = new NativeFunction(so.add(0x19F3A94), 'pointer', ['pointer'])
        var Geturl = new NativeFunction(so.add(0x19F3CAC), 'pointer', ['pointer'])
        var GetManifest = new NativeFunction(so.add(0x19F3D74), 'pointer', ['pointer'])
        var GetAppVer = new NativeFunction(so.add(0x19F3D74), 'pointer', ['pointer'])
        var GetResPath = new NativeFunction(so.add(0x19F3F8C), 'pointer', ['pointer'])
        var SetFightState = new NativeFunction(so.add(0x167D838), 'void', ['int'])
        

        var addr = so.add(0x2FB9CF4)
        Interceptor.attach(addr, {
            onEnter: function (args) {
                console.log('enter')
                // console.log(args[1].readByteArray(0x100))
                // console.log(args[1].readByteArray(0x100))
                // console.log(args[1].readByteArray(0x100))
            },
            onLeave: function(retval){
                // console.log(retval.add(0xE).readUtf16String())
                return retval
            }
        })
    })
}


setTimeout(run, 1000)