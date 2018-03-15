/*
 * SPI testing utility (using spidev driver)
 *
 * Copyright (c) 2007  MontaVista Software, Inc.
 * Copyright (c) 2007  Anton Vorontsov <avorontsov@ru.mvista.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 *
 * Cross-compile with cross-gcc -I/path/to/cross-kernel/include
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>


static void pabort(const char *s) {
  perror(s);
  abort();
}


#define BYTES_PER_TRANSFER 8192

static const char *device = "/dev/spidev0.0";
static uint8_t mode = SPI_MODE_0;
static uint8_t bits_per_word = 8;
static uint32_t speed = 2000000;  // 2MHz -> 8x over-sampling
static uint16_t delay = 0;

int ret;
uint8_t rx[BYTES_PER_TRANSFER*4] = {0, };

static void transfer(int fd, int offset) {
  struct spi_ioc_transfer tr = {
    // don't transmit anything
    .tx_buf = 0,

    // save received bytes into `rx` buffer (at appropriate offset)
    .rx_buf = (unsigned long)(rx + BYTES_PER_TRANSFER*offset),

    // bytes to send/receive in this transfer operation
    .len = BYTES_PER_TRANSFER,

    // don't delay after data bytes are sent
    .delay_usecs = delay,

    // overwrite speed temporarily to 2MHz
    .speed_hz = speed,

    // overwrite bits per word temporarily to 8
    .bits_per_word = bits_per_word,
  };

  // 1 specifies number of transfers to make (if `tr` was an array)
  ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
  if (ret < 1) {
    pabort("can't send spi message");
  }
}


#define BYTE_TO_BINARY_PATTERN "%c %c %c %c %c %c %c %c "
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')


static void printBinary() {
  int i;
  int j;

  for (i = 0; i < 4; i++) {
    for (j = 0; j < BYTES_PER_TRANSFER; j++) {
      printf(BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(rx[BYTES_PER_TRANSFER*i + j]));
    }
    printf("\n\n");
  }
}

static void printCArray() {
  int i;
  int j;

  for (i = 0; i < 4; i++) {
    printf("uint8_t data_lines%d[] = {\n    ", i);
    for (j = 0; j < BYTES_PER_TRANSFER; j++) {
      alternatively: printf("0x%02x, ", rx[BYTES_PER_TRANSFER*i + j]);

      if ((j+1) % 16 == 0) {
        printf("\n    ");
      }
      else if ((j+1) % 8 == 0) {
        printf(" ");
      }
    }
    printf("};\n");
  }
}

int main(int argc, char *argv[]) {
  int ret = 0;
  int fd;

  fd = open(device, O_RDWR);
  if (fd < 0) {
    pabort("can't open device");
  }

  /*
   * spi mode
   */
  ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
  if (ret == -1) {
    pabort("can't set spi mode");
  }

  ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
  if (ret == -1) {
    pabort("can't get spi mode");
  }

  /*
   * bits per word
   */
  ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits_per_word);
  if (ret == -1) {
    pabort("can't set bits per word");
  }

  ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits_per_word);
  if (ret == -1) {
    pabort("can't get bits per word");
  }

  /*
   * max speed hz
   */
  ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
  if (ret == -1) {
    pabort("can't set max speed hz");
  }

  ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
  if (ret == -1) {
    pabort("can't get max speed hz");
  }

  printf("// spi mode: %d\n", mode);
  printf("// bits per word: %d\n", bits_per_word);
  printf("// max speed: %d Hz = %d kHz\n", speed, speed/1000);

  int i;
  for(i = 0; i<4; i++) {
    transfer(fd, i);
  }

  printBinary();
  // printCArray();

  close(fd);

  return ret;
}
