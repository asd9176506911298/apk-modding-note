h5gg.require(7.9); //设定最低需求的H5GG版本号//min version support for H5GG
var h5frida=h5gg.loadPlugin("h5frida", "h5frida-15.1.24.dylib");
if(!h5frida) throw "加载h5frida插件失败\n\nFailed to load h5frida plugin";
if(!h5frida.loadGadget("frida-gadget-15.1.24.dylib"))
    throw "加载frida-gadget守护模块失败\n\nFailed to load frida-gadget daemon module";
var procs = h5frida.enumerate_processes();
if(!procs || !procs.length) throw "frida无法获取进程列表\n\nfrida can't get process list";
var pid = -1; //pid=-1, 使用自身进程来调用OC/C/C++函数, 也可以附加到其他APP进程来调用
var found = false;
for(var i=0;i<procs.length;i++) {
    if(procs[i].pid==pid) {
        if(procs[i].name!='Gadget') throw "免越狱测试请卸载frida-server的deb然后重启当前APP\nFor non-jailbreak tests, please uninstall the frida-server deb and restart the current APP";
        found = true;
    }
}
if(!found) throw "frida无法找到目标进程\n\nfrida cannot find the target process";
var session = h5frida.attach(pid);
if(!session) throw "frida附加进程失败\n\nfrida attach process failed";

//监听frida目标进程连接状态, 比如异常退出
session.on("detached", function(reason) {
    alert("frida目标进程会话已终止(frida target process session terminated):\n"+reason);
});

var frida_script_line = frida_script("getline"); //safari console will auto add 2 line
var frida_script_code = "("+frida_script.toString()+")()"; //将frida脚本转换成字符串
var script = session.create_script(frida_script_code); //注入frida的js脚本代码

if(!script) throw "frida注入脚本失败\n\nfrida inject script failed!";
script.on('message', function(msg) {
    if(msg.type=='error') {
        script.unload(); //如果脚本发生错误就停止frida脚本
        try {if(msg.fileName=="/frida_script.js") msg.lineNumber += frida_script_line-1;} catch(e) {}
        if(Array.isArray(msg.info)) msg.info.map(function(item){ try { if(item.fileName=="/frida_script.js")
            item.lineNumber += frida_script_line-1;} catch(e) {}; return item;});
        var errmsg = JSON.stringify(msg,null,1).replace(/\/frida_script\.js\:(\d+)/gm,
            function(m,c,o,a){return "/frida_script.js:"+(Number(c)+frida_script_line-1);});
        alert("frida(脚本错误)script error:\n"+errmsg.replaceAll("\\n","\n"));
    }
    
    if(msg.type=='send')
        alert("frida(脚本消息)srcipt msg:\n"+JSON.stringify(msg.payload,null,1));
    if(msg.type=='log')
        alert("frida(脚本日志)script log:\n"+msg.payload);
});

if(!script.load()) throw "frida启动脚本失败\n\nfrida load script failed"; //启动脚本
function frida_script() { if(arguments.length) return new Error().line; 
                         
// Namespace: SYBO.Subway.Characters
//public class Character : CharacterBase             
    //public float JumpHeight; // 0x16C

    //public override void Jump() { } 0x2C13CB4
    //protected void _Update() { } 0x2C12650
var jump = new NativeFunction(Module.findBaseAddress('UnityFramework').add(0x2C13CB4), "void", ["pointer"]);

var update = h5frida.StaticInlineHookFunction("Frameworks/UnityFramework.framework/UnityFramework",
    0x2C12650,
    "void",
    ["pointer"],
    function(instance) {
        // jump(instance);
        // console.log(instance.add(0x16C).readFloat());
        instance.add(0x16C).writeFloat(100); //跳躍高度預設20
        return update(instance)
    }
);
                        
   
}