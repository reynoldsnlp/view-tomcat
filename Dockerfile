FROM tomcat:8.5-jre8

COPY conf /usr/local/tomcat/conf/

ENV runtime_dependencies "cg3"
ENV build_dependencies "git"

RUN curl -L https://apertium.projectjj.com/apt/apertium-packaging.public.gpg \
  > /etc/apt/trusted.gpg.d/apertium.gpg \
 && curl -L https://apertium.projectjj.com/apt/apertium.pref \
  > /etc/apt/preferences.d/apertium.pref \
 && echo "deb http://apertium.projectjj.com/apt/nightly jessie main" \
  > /etc/apt/sources.list.d/apertium-nightly.list \
 && apt-get -qy update \
 && apt-get install -y $runtime_dependencies $build_dependencies \
 && mkdir -p /usr/local/werti \
 && mkdir -p /usr/local/werti/resources \
 && tmp=$(mktemp -d) \
 && cd $tmp \
 && git clone https://github.com/linziheng/pdtb-parser \
 && mv pdtb-parser/lib/morph/morphg /usr/local/bin \
 && mv pdtb-parser/lib/morph/verbstem.list /usr/local/werti/resources \
 && rm -rf pdtb-parser \
 && apt-get remove -y $build_dependencies \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf $tmp

RUN groupadd -g 1003 view \
 && useradd -u 1003 -g 1003 view \
 && chown -R view:view /usr/local/tomcat

RUN mkdir -p /usr/local/view/db \
 && chown -R view:view /usr/local/view/db

VOLUME /usr/local/tomcat/webapps
VOLUME /usr/local/view/db

USER view
CMD ["catalina.sh", "run"]
