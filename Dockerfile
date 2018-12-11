FROM python:3.6
RUN useradd --user-group --create-home --shell /bin/bash work
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/home/work
RUN apt-get update -y
RUN apt-get install -y apt-transport-https apt-utils
RUN apt-get update -y && apt-get install -y build-essential libssl-dev \
    libffi-dev python3-dev libsasl2-dev libldap2-dev libxi-dev
RUN apt-get install -y vim less postgresql-client redis-tools
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update; \
    apt-get install -y yarn
RUN mkdir $HOME/incubator-superset
WORKDIR $HOME/incubator-superset
COPY ./ ./
RUN mkdir -p /home/work/.cache
RUN pip install --upgrade setuptools pip
RUN pip install -r requirements.txt
RUN pip install -r requirements-dev.txt
RUN pip install -e .
ENV PATH=/home/work/incubator-superset/superset/bin:$PATH \
    PYTHONPATH=./superset/:$PYTHONPATH
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
COPY ./superset ./superset
RUN chown -R work:work $HOME
#USER work
RUN cd superset/assets && yarn
RUN cd superset/assets && npm run build
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 8088
