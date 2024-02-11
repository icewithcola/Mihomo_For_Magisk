import os
import requests
import yaml

def fix_t(file:str):
    '''
    修复文件中`\t`会使得yaml读取失败的问题
    '''
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
        content = content.replace('\t', '  ')
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
        

def download_provider(folder:str):
    '''
    下载的folder中的provider的url至path。
    Args:
        folder: clash运行配置所在文件夹的绝对路径
    config.yaml样例:
    ```yaml
        proxy-providers:
          A:
            type: http
            url: "https://example.com/A.yaml"
            path: ./proxy_providers/A.yaml
    ```
    会将A.yaml下载至 ./clash/proxy_providers/A.yaml
    '''
    if not os.path.exists(folder):
        print(f"{folder} 不存在")
        return
    conf_file = os.path.join(folder, 'config.yaml')
    fix_t(conf_file)
    
    with open(conf_file, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
        try:
            proxy_providers = config['proxy-providers']
            for _,v in proxy_providers.items():
                url = v['url']
                path = v['path']
                if v['type']=="http":
                    destination = os.path.join(folder,path[2:])
                    print(f"正在下载至 {destination}")
                    r = requests.get(url)
                    with open(destination, 'wb') as f:
                        f.write(r.content)
                        print(f"下载成功")
        except KeyError:
            print("没有proxy-providers,跳过")
            
        try:
            rule_providers = config['rule-providers']
            for _,v in rule_providers.items():
                url = v['url']
                path = v['path']
                if v['type']=="http":
                    destination = os.path.join(folder,path[2:])
                    print(f"正在下载至 {destination}")
                    r = requests.get(url)
                    with open(destination, 'wb') as f:
                        f.write(r.content)
                        print(f"下载成功")          
        except KeyError:
            print("没有rule-providers,跳过")
                
if __name__=="__main__":
    
    if os.sys.argv.__len__()>1:
        download_provider(os.sys.argv[1])
    else:
        download_provider('clash')