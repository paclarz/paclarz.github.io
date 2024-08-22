# 使用 jekyll/jekyll 镜像
FROM jekyll/jekyll

# 设置工作目录
WORKDIR /srv/jekyll

COPY Gemfile ./
RUN bundle 

COPY . .

# 貌似是个必须通过修改git版本来解决的警告bug
RUN  git config --global safe.directory '*'

# 暴露端口 4000
EXPOSE 4000

# 运行 jekyll serve --auto 命令
CMD ["jekyll", "serve"]
