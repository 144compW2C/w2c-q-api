FROM ruby:3.3.8

# タイムゾーンを JST に設定
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 作業ディレクトリ
WORKDIR /service

# 先にGemfileとLockをコピー（キャッシュ活用のため）
COPY Gemfile Gemfile.lock ./

# Bundler install（ここで失敗する場合はエラーを確認）
RUN bundle install

# アプリ本体をコピー
COPY . .

# ポート解放
EXPOSE 8080

# Rails起動コマンド
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]