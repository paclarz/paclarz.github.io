FROM ubuntu:22.04

# 配置清华源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt update 

# 安装基本依赖
RUN apt-get install -y \
    git \
    build-essential \
    python3 \
    nodejs 

RUN apt install -y \
    libz-dev libssl-dev libffi-dev libyaml-dev

# 安装ruby版本管理工具rbenv
RUN apt install -y  rbenv

RUN  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN  echo 'eval "$(rbenv init -)"' >> ~/.bashrc 

# 安装ruby并配置环境变量
RUN  rbenv install 3.2.5
RUN  rbenv global 3.2.5
ENV PATH /root/.rbenv/shims:$PATH

# 安装bundler
RUN apt install -y bundler

EXPOSE 4000
WORKDIR /app

# -------------------------------------------------------------- 开发模板

WORKDIR /app/jekyll
COPY Gemfile .
RUN bundle 

COPY . .

CMD bundle exec jekyll serve --host 0.0.0.0

# -------------------------------------------------------------- 测试模板

# RUN git clone https://github.com/cotes2020/chirpy-starter.git

# WORKDIR /app/chirpy-starter

# # 安装依赖
# RUN bundle

# # 测试命苦
# # CMD ["tail", "-f", "/dev/null"]
# # 启动服务
# CMD bundle exec jekyll serve --host 0.0.0.0

