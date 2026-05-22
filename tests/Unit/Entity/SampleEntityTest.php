<?php

namespace App\Tests\Unit\Entity;

use App\Entity\SampleEntity;
use PHPUnit\Framework\TestCase;

class SampleEntityTest extends TestCase
{
    public function test_initializes_timestamps_when_created(): void
    {
        $entity = new SampleEntity();

        self::assertInstanceOf(\DateTimeImmutable::class, $entity->getCreatedAt());
        self::assertInstanceOf(\DateTimeImmutable::class, $entity->getUpdatedAt());
    }

    public function test_updates_name(): void
    {
        $entity = new SampleEntity();

        $entity->setName('Example');

        self::assertSame('Example', $entity->getName());
    }
}
