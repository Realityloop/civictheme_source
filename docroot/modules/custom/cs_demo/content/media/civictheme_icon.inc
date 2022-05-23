<?php

/**
 * @file
 * Create demo icons.
 */

use Drupal\Core\Link;
use Drupal\cs_demo\CsDemoHelper;
use Drupal\cs_demo\CsDemoRandom;
use Drupal\media\Entity\Media;

/**
 * Implements hook_cs_demo_create_ENTITY_TYPE_BUNDLE_weight().
 */
function cs_demo_create_media_civictheme_icon_weight() {
  return 0;
}

/**
 * Implements hook_cs_demo_create_ENTITY_TYPE_BUNDLE_tracking().
 */
function cs_demo_create_media_civictheme_icon_tracking() {
  return TRUE;
}

/**
 * Implements hook_cs_demo_create_ENTITY_TYPE_BUNDLE().
 */
function cs_demo_create_media_civictheme_icon() {
  $helper = CsDemoHelper::getInstance();
  /** @var \Drupal\cs_demo\CsGenerator $generator */
  $generator = Drupal::getContainer()->get('cs_demo.generator');

  $total_files_count = 20;

  $entities = [];
  for ($i = 0; $i < $total_files_count; $i++) {
    $filename = sprintf('Demo Icon %s %s', $i + 1, CsDemoRandom::sentence(2, 2));
    /** @var \Drupal\file\Entity\File $file */
    $file = $generator->createFromDummyFile([
      'filename' => $filename,
      'extension' => 'svg',
    ]);

    $media = Media::create([
      'bundle' => 'civictheme_icon',
      'name' => $filename,
    ]);

    $media->field_c_m_icon->setValue($file->id());
    $media->save();

    $helper::log(
      'Created media icon for file "%s" (id: %s)',
      Link::createFromRoute($file->getFilename(), 'entity.media.canonical', ['media' => $media->id()])->toString(),
      $media->id()
    );

    $entities[$media->id()] = $media;
  }

  return $entities;
}