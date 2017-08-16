#从西刺代理获取代理IP
module Proxy
  class GetXiciProxy
    def self.main 
      n = 0
      url = "http://www.xicidaili.com/nn/"
      while true
        n+=1
        parse_ip(url+n.to_s)
        if n ==4
          n=0
        end
      end 
    end

    #解析IP,并存入将可用的存入数据库中
    def self.parse_ip(url)
      ##如果本地ip，被封这里会有点问题，
      #会存在每次去请求页面第一次都会带上本机的ip
      #造成在本机被封时，每第一次都会时失败
      #需要想办法保存下来当前有效的ip，避免这个问题
      #留坑~~~~
      html = Common.html(url)
      #这个地方有待商榷，
      while !html
        ip_post = Common.random_proxy("西刺代理").split(":")
        html = Common.html(url,true,ip_post[0],ip_post[1].to_i)
      end
      html.xpath('//table[@id="ip_list"]/tr').each do |tr|
        flag = 0
        ip = ''
        post = ''
        tr.xpath('td').each do |td|
          flag +=1
          str = td.content.gsub("\n","").gsub(" ","")
          if flag ==2
            ip = str
          end
          if flag ==3
            post = str
            #验证代理是否能用,将能用的代理存入数据库
            now_time = Time.new
            if Common.time_out?(ip,post.to_i)
              time_consuming = Time.new - now_time
              source = '西刺代理'
              Common.save(ip,post,source,time_consuming)
            end
            break
          end
        end
      end
    end
  end
end
