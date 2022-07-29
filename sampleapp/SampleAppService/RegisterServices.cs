using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;
using StackExchange.Redis;

namespace SampleAppService;

public static class RegisterStartupServices
{

    public static WebApplicationBuilder RegisterServices(this WebApplicationBuilder builder)
    {
        //Add Options Pattern
        builder.Services.AddOptions();
        builder.Services.AddOptions<SampleAppServiceOptions>().Bind(builder.Configuration.GetSection(SampleAppServiceOptions.Section));

        var sp = builder.Services.BuildServiceProvider();
        var options = sp.GetService<IOptions<SampleAppServiceOptions>>();

        if (options != null && options.Value.AddRedis)
        {
            //Configure Redis
            var endpoint = options.Value.GetRedisEnpoint();
            var redisConnection = ConnectionMultiplexer.Connect(endpoint);
            builder.Services.AddSingleton<IConnectionMultiplexer>(redisConnection);
        }

        // Add services to the container.
        builder.Services.AddRazorPages();
        builder.Services.AddHealthChecks().AddCheck("default", () => {
            // TODO: need "real world" validation for dependencies
            // see https://docs.microsoft.com/en-us/azure/architecture/patterns/health-endpoint-monitoring
            return HealthCheckResult.Healthy();
        });

        return builder;
    }
}

