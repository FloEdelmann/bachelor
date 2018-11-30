View this project on [CADLAB.io](https://cadlab.io/project/1483). 

# Bachelor's Thesis *Using a Raspberry Pi as a PC-DMX interface*

## Florian Edelmann, November 2017

Official university page: [www.mnm-team.org/pub/Fopras/edel17/](http://www.mnm-team.org/pub/Fopras/edel17/)

**Abstract**

DMX is a common standard in the entertainment technology industry that allows controlling lighting fixtures (like spotlights or strobe lights on a stage) connected over a bus. The DMX source driving the bus is usually a mixing desk console; alternatively, lighting control software on a computer together with a physical PC-DMX interface is often used. The high costs of professional desk consoles and DMX interfaces limits small associations like youth groups to less expensive interfaces that often lack useful features.

This Bachelor's Thesis defines requirements for a PC-DMX interface in this use case, including a price limit and advanced features like the availability of a DMX input port to enable haptic control of software functions. A market study is conducted, which reveals that no existing products match all requirements, so a system design is established, building upon the affordable single-board computer Raspberry Pi. The software basis is provided by *Open Lighting Architecture* (*OLA*), an open-source software that is able to convert different protocols to and from DMX and process the data internally.

OLA is then extended to support DMX output through a USB-DMX adapter by reverse engineering and implementing its protocol. DMX input directly on Raspberry Pi's hardware is possible for the first time through the implementation of SPI bus sampling; other tested approaches were not successful. The validation of the finished PC-DMX interface shows satisfactory fulfillment of the requirements. Future work to improve the system design by making it even less expensive, more easy to use or by adding extra features is possible.

**Full PDF**

see [`edel17.pdf`](edel17.pdf)


### Meta

Written in [Pandoc Markdown](https://pandoc.org/MANUAL.html): [`edel17.md`](edel17.md), [`abstract.md`](abstract.md)

[`Makefile`](Makefile) builds the PDF [`edel17.pdf`](edel17.pdf):

* compile Markdown to LaTeX using Pandoc (with custom filter [`pandoc-filter.js`](pandoc-filter.js))
* replace some strings in the resulting LaTeX code using [`pandoc-postprocessing.js`](pandoc-postprocessing.js)
* run `pdflatex` to create the PDF
* compress it with `gs` (reduces image resolution)
