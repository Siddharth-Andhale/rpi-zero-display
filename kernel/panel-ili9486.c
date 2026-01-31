/*
 * DRM/KMS driver for ILI9486 SPI panels
 *
 * Copyright (C) 2024
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <linux/delay.h>
#include <linux/module.h>
#include <linux/spi/spi.h>
#include <linux/gpio/consumer.h>

#include <video/mipi_display.h>
#include <drm/drm_mipi_dbi.h>
#include <drm/drm_print.h>
#include <drm/drm_drv.h>
#include <drm/drm_gem_dma_helper.h>
#include <drm/drm_probe_helper.h>
#include <drm/drm_atomic_helper.h>

/* ... (commands macros) ... */
/* ... (init sequence) ... */

static const struct drm_simple_display_pipe_funcs ili9486_pipe_funcs = {
	.enable = mipi_dbi_pipe_enable,
	.disable = mipi_dbi_pipe_disable,
	.update = mipi_dbi_pipe_update,
};

static const struct drm_display_mode ili9486_mode = {
	DRM_SIMPLE_MODE(480, 320, 73, 49),
};

DEFINE_DRM_GEM_DMA_FOPS(ili9486_fops);

static const struct drm_driver ili9486_driver = {
	.driver_features	= DRIVER_GEM | DRIVER_MODESET | DRIVER_ATOMIC,
	.fops			= &ili9486_fops,
	DRM_GEM_DMA_DRIVER_OPS_WITH_DUMB_CREATE(drm_gem_dma_dumb_create),
	.debugfs_init       = mipi_dbi_debugfs_init,
	.name			= "ili9486",
	.desc			= "Ilitek ILI9486",
	.date			= "20240130",
	.major			= 1,
	.minor			= 0,
};

static int ili9486_probe(struct spi_device *spi)
{
	struct device *dev = &spi->dev;
	struct mipi_dbi_dev *dbidev;
	struct drm_device *drm;
	struct mipi_dbi *dbi;
	struct gpio_desc *dc_gpio;
	int ret;

	dbidev = devm_drm_dev_alloc(dev, &ili9486_driver,
				    struct mipi_dbi_dev, drm);
	if (IS_ERR(dbidev))
		return PTR_ERR(dbidev);

	dbi = &dbidev->dbi;
	drm = &dbidev->drm;

	dc_gpio = devm_gpiod_get_optional(dev, "dc", GPIOD_OUT_LOW);
	if (IS_ERR(dc_gpio)) {
		dev_err(dev, "Failed to get DC gpio\n");
		return PTR_ERR(dc_gpio);
	}

	dbi->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
	if (IS_ERR(dbi->reset)) {
		dev_err(dev, "Failed to get reset gpio\n");
		return PTR_ERR(dbi->reset);
	}

	ret = mipi_dbi_spi_init(spi, dbi, dc_gpio);
	if (ret)
		return ret;

	ret = mipi_dbi_dev_init(dbidev, &ili9486_pipe_funcs, &ili9486_mode, 0);
	if (ret)
		return ret;

	drm_mode_config_reset(drm);

	ret = ili9486_init(dbi);
	if (ret) {
		dev_err(dev, "Failed to send init sequence\n");
		return ret;
	}

	return drm_dev_register(drm, 0);
}

static void ili9486_remove(struct spi_device *spi)
{
	struct drm_device *drm = spi_get_drvdata(spi);

	drm_dev_unregister(drm);
	drm_atomic_helper_shutdown(drm);
}

static void ili9486_shutdown(struct spi_device *spi)
{
	drm_atomic_helper_shutdown(spi_get_drvdata(spi));
}

static const struct spi_device_id ili9486_id[] = {
	{ "ili9486", 0 },
	{ }
};
MODULE_DEVICE_TABLE(spi, ili9486_id);

static const struct of_device_id ili9486_of_match[] = {
	{ .compatible = "ilitek,ili9486" },
	{ }
};
MODULE_DEVICE_TABLE(of, ili9486_of_match);

static struct spi_driver ili9486_spi_driver = {
	.driver = {
		.name = "ili9486",
		.of_match_table = ili9486_of_match,
	},
	.id_table = ili9486_id,
	.probe = ili9486_probe,
	.remove = ili9486_remove,
	.shutdown = ili9486_shutdown,
};
module_spi_driver(ili9486_spi_driver);

MODULE_DESCRIPTION("Ilitek ILI9486 DRM driver");
MODULE_AUTHOR("Sarthak <user@example.com>");
MODULE_LICENSE("GPL");
