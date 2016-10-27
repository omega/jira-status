FROM eu.gcr.io/divine-arcade-95810/perl:jessie

COPY cpanfile .
RUN cpanm --notest --installdeps .

COPY . .

EXPOSE 5000

CMD plackup
