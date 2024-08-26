import os
import xxtea
import zlib
 
##Get All jsc files in the current directory
def getFileList():
    fs=[]
    dirpath='D:\\apk\\apk\\snake Master'
    for root,dirs,files in os.walk(dirpath):
        for file in files:
            if(file.endswith('.jsc')):
                fs.append(os.path.join(root,file))
    return fs
   
def Fix(path,key):
    f1=open(path,'rb').read()
    print("Decrypting:%s"%(path))
    d1=xxtea.decrypt(f1,key)
    d1=zlib.decompress(d1,16+zlib.MAX_WBITS)
    print("Decryption complete:%s"%(path))
    f2=open(path.replace('.jsc','.js'),'wb')
    f2.write(d1)
     
def run(key):
    for f in getFileList():
        #print(f)
        Fix(f,key)
         
 
key = ";12>fd2k<I.?`=@"
run(key)