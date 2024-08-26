import os
import xxtea
import zlib
 
##Get All jsc files in the current directory
def getFileList():
    fs=[]
    dirpath='D:\\apk\\apk\\snake Master'
    for root,dirs,files in os.walk(dirpath):
        for file in files:
            if(file.endswith('.js')):
                fs.append(os.path.join(root,file))
    return fs
   
def Fix(path,key):
    f1=open(path,'rb').read()
    print("Encrypting:%s"%(path))
    d1=xxtea.encrypt(f1,key)
    print("Encryption complete:%s"%(path))
    f2=open(path.replace('.js','.jsc'),'wb')
    f2.write(d1)
     
def run(key):
    for f in getFileList():
        #print(f)
        Fix(f,key)
         
 
key = ";12>fd2k<I.?`=@"
run(key)