<?php

namespace App\Tests\Integration\Routing;

use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\Routing\RouterInterface;

class RouteRegistrationTest extends KernelTestCase
{
    public function test_registers_homepage_and_admin_routes(): void
    {
        self::bootKernel();

        $router = self::getContainer()->get(RouterInterface::class);
        $routes = $router->getRouteCollection();

        self::assertNotNull($routes->get('app_homepage'));
        self::assertNotNull($routes->get('admin'));
    }
}
