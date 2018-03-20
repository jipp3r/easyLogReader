# easyLogReader

Extract data from Easylog device files, and produce summary statistics

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Use:

```
install.packages('XML')
install.packages('dplyr')
install.packages('ggplot2')
install.packages('grid')
install.packages('scales')
install.packages('stringr')
install.packages('flux')
```

### Installing

Open R, and type:
```
devtools::install_git("https://github.com/jipp3r/easyLogReader.git")
```
If you do not have the package "devtools", first install it from CRAN with:
```
install.packages("devtools")
```

## Output format
easyLogReader produces an R dataframe.

## Disclaimer

Although efforts have been made to verify correct operation of this software, I cannot accept any liability arising from its use. The software is provided "as is", without any express or implied warranty, and no implication of fitness for a particular use.

## Authors

* **Jamie Rylance** - *Initial work* - [jipp3r](https://github.com/jipp3r)

## License

This project is licensed under the GPL3 license


