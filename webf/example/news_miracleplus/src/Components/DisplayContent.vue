<template>
    <div class="display-content">
      <!-- Title -->
      <div class="title">{{ truncatedTitle }}</div>
  
      <div class="content-wrapper">
        <!-- Logo Image -->
        <smart-image :src="logoUrl" class="logo-image" />
        
        <div class="text-content">
          <!-- Description -->
          <p class="description">{{ truncatedContent }}</p>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import SmartImage from '@/Components/SmartImage.vue';
  
  const defaultLinkLogo = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNzAiIGhlaWdodD0iNzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIG92ZXJmbG93PSJoaWRkZW4iPjxkZWZzPjxjbGlwUGF0aCBpZD0iYSI+PHBhdGggZD0iTTIzOCAyNDFoNzB2NzFoLTcweiIvPjwvY2xpcFBhdGg+PGNsaXBQYXRoIGlkPSJiIj48cGF0aCBkPSJNMCAwaDY1NzIyNXY2NTcyMjVIMHoiLz48L2NsaXBQYXRoPjxjbGlwUGF0aCBpZD0iYyI+PHBhdGggZD0iTTAgMGg2NTcyMjV2NjU3MjI1SDB6Ii8+PC9jbGlwUGF0aD48aW1hZ2Ugd2lkdGg9IjkzIiBoZWlnaHQ9IjkzIiB4bGluazpocmVmPSJkYXRhOmltYWdlL2pwZWc7YmFzZTY0LC85ai80QUFRU2taSlJnQUJBUUVBWUFCZ0FBRC8yd0JEQUFNQ0FnTUNBZ01EQXdNRUF3TUVCUWdGQlFRRUJRb0hCd1lJREFvTURBc0tDd3NORGhJUURRNFJEZ3NMRUJZUUVSTVVGUlVWREE4WEdCWVVHQklVRlJULzJ3QkRBUU1FQkFVRUJRa0ZCUWtVRFFzTkZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlFVRkJRVUZCUVVGQlQvd0FBUkNBQmRBRjBEQVNJQUFoRUJBeEVCLzhRQUh3QUFBUVVCQVFFQkFRRUFBQUFBQUFBQUFBRUNBd1FGQmdjSUNRb0wvOFFBdFJBQUFnRURBd0lFQXdVRkJBUUFBQUY5QVFJREFBUVJCUkloTVVFR0UxRmhCeUp4RkRLQmthRUlJMEt4d1JWUzBmQWtNMkp5Z2drS0ZoY1lHUm9sSmljb0tTbzBOVFkzT0RrNlEwUkZSa2RJU1VwVFZGVldWMWhaV21Oa1pXWm5hR2xxYzNSMWRuZDRlWHFEaElXR2g0aUppcEtUbEpXV2w1aVptcUtqcEtXbXA2aXBxckt6dExXMnQ3aTV1c0xEeE1YR3g4akp5dExUMU5YVzE5aloydUhpNCtUbDV1Zm82ZXJ4OHZQMDlmYjMrUG42LzhRQUh3RUFBd0VCQVFFQkFRRUJBUUFBQUFBQUFBRUNBd1FGQmdjSUNRb0wvOFFBdFJFQUFnRUNCQVFEQkFjRkJBUUFBUUozQUFFQ0F4RUVCU0V4QmhKQlVRZGhjUk1pTW9FSUZFS1JvYkhCQ1NNelV2QVZZbkxSQ2hZa05PRWw4UmNZR1JvbUp5Z3BLalUyTnpnNU9rTkVSVVpIU0VsS1UxUlZWbGRZV1ZwalpHVm1aMmhwYW5OMGRYWjNlSGw2Z29PRWhZYUhpSW1La3BPVWxaYVhtSm1hb3FPa3BhYW5xS21xc3JPMHRiYTN1TG02d3NQRXhjYkh5TW5LMHRQVTFkYlgyTm5hNHVQazVlYm42T25xOHZQMDlmYjMrUG42LzlvQURBTUJBQUlSQXhFQVB3RDVTb29vb0FLS0tLQUNpaWlnQW9vb29BS0tLS0FDaWlpZ0Fvb29vQUtLS0tBQ3JPbTZiZDZ6cUZ0WVdGdExlWHR6SXNNRnZBaGVTUjJPRlZWSEpKSjZWRmIyOHQzY1JRUW8wczByQkVSUmtzeE9BQitOZnFIK3l2OEFzcjZGK3pQNFRuK0lIeEFudEl2RThkczAwMXhjT0RCbzhKSHpLcmRESVFjTXc5ZHE4WkxBSEQvQXovZ216bzlqbzhHdGZGVytsdUx4azgxOUVzcC9LZ3QxeG5Fc3crWmlCMTJGUU9lVzYxNlNud1AvQUdUZFh1UDdCdC8rRVFsdm1QbHJiMjNpSS9hZDNvQ0o5eFB0WHgxKzF0KzJGcTN4NjFxYlI5RG11Tks4Q1d6bFliVU1VZStJUCt0bUE3Y2ZLaDRIVTg5UG15Z0Q3bi9hUS80SnpTZUZkSHZQRWZ3enViclZMVzJVeTNHZzNaRDNDb09TMERnRGZnZndFYnVPQ3g0cjRZcjc3LzRKei90SmF6cVhpQnZoaDRpdnBOUnRYdG5uMGFlNFl0SkMwWTNQQms4bE5nWmwvdTdDQndSancvOEFiMCtGbHA4TVAyZ05RT213TGJhWnIxdW1yeFF4akN4dTdNc3FqMC9lSXpZN0J3S0FQblNpaWlnQW9vb29BS3M2YnB0M3JPb1cxaFlXMHQ1ZTNNaXd3VzhDRjVKSFk0VlZVY2trbnBScHVtM2VzNmhiV0ZoYlMzbDdjeUxEQmJ3SVhra2RqaFZWUnlTU2VsZnA5K3l2K3l2b1g3TS9oT2Y0Z2ZFQ2UwaThUeDJ6VFRYRnc0TUdqd2tmTXF0ME1oQnd6RDEycnhrc0FmbWY0dDhJNno0RDhRM21oZUlOTm4wblZyTnRrOXJjTGhsT01nK2hCQkJCSEJCQkZkaDQwL2FHOGUvRUQ0ZjZKNE0xelhwcnpRdEovd0JWRTNEelkrNTV6ZFpOZzRYUFQ2ODEyUDdZSDdSVnIrMFI4UkliN1ROTWlzZEYwcU5yU3l1SGlDM1YwaGJKZVZ1dU1qS3AvQ0NlN0d2U1AyTGYyTFp2aXJjMnZqWHhyYXlRZURZWDMybGpJQ3I2b3dQVTl4Q0QxUDhBRjBIR1RRQnpmN092N0MvaVg0NmVEOVI4UzNsNy93QUkxcHJ3c05JZTRoTEc5bUhSaU9xdzVHTi9KSjZBNE5mTy9pbncxZjhBZzN4SnFlaGFwR3NPcGFiY3lXdHhISElycXNpTVZZQmxKQjVIVVYraFg3WjM3WjBIZ0d6dVBoeDhPTGlPTFY0MCt5MytwMmVGVFRrQTIrUkRqZ1NBY0VqN25RZk45ejRpK0N2d1Y4Uy9Ienh4RG9HZ1FsbVkrYmU2aE1DWWJTTFBNa2gva09ySGdVQWV2LzhBQk9ud1BmOEFpVDlvelQ5YmdqYjdCNGV0Ymk2dVpzZktESkU4Q0puMUprSkE5RWIwcm9QK0NuWGlPMjFUNDRhTnBjREs4dWw2Tkd0eGpxc2tra2poVC93QW8zL0FxK3I5VzFiNGRmc0EvQlNPMXRVRnpxTTRQa3dFZ1hlcjNZVVpkei9DZzR5ZWlMZ0RKSUIvSzN4MTQwMVg0amVNTlc4VGEzUDlwMVRVN2hyaWR4d0FUMFZSMlZSaFFPd0FGQUdGUlJSUUFVVVVVQWZkSC9CTVg0UVdtdGE1ci94QzFHM1djNlN5NmZwdThaQ1R1dTZXUWY3U29VVWUwalY1NSszTCswNXFmeFc4ZWFsNFAwdTZhMzhHNkhkdGJpR0k0RjdjUmtxOHIrcWhnUWc2WUc3cWVQby8vZ2x6ck50Y2ZCdnhScFNNdjJ5MTExcm1SQjFDUzI4S29UOVRFLzVWK2VmeFM4TDMvZ3Y0a2VKdEQxTkhTK3NkUm5oazNqbHNPY043aGhoZ2U0SU5BSGVmc2wrRS9BWGpQNDA2UnB2eEN2OEE3SnBMODI5dS93QXNONWM1SGx3U3ZuNUZibi9lSUM1R2ErdXYyenYyem9QQU5uY2ZEajRjWEVjV3J4cDlsdjhBVTdQQ3BweUFiZkloeHdKQU9DUjl6b1BtKzUrY05lZ2ZCUDRKK0pQajE0Mmc4UGVIb01uaVM4djVRZkpzNHM4eU9mNUwxWThDZ0RnR1pwR0xNU3pNY2xpY2ttdnJYOWtmOXMzUlAyZi9BSWYrSU5BMWJ3MTlwdUNXdkxHN3NGVlpMdVk0QWl1R1BSUjJjWndNakI0ejZiKzFoK3pqOEhQZ24renhwMWtaRFkrTDdZbit6YjZOUTE1cXM1eDVnbVhQTVhmUFNQakdTZHIvQUorVUFkajhXUGl4NGkrTkhqUzg4VGVKYnczTjdPZHNjUzVFVnRFQ2RzVWEvd0FLalAxSkpKSkpKcmpxS0tBQ2lpaWdBb29vb0E5ci9aTi9hR20vWjMrSmlhbmNSeVhQaDNVVUZwcXR0RnkzbDV5c3FEdTZIa0R1Q3c0emtmZkh4cy9aaStIL0FPMkZvdGo0ejhPYTdEWmF2TkFGaDF6VDFFMFZ5Z0hDVHg1QkxMMDZobDZIT0FCK1RsZFg0QitLL2pINFczajNQaFB4SnFHaFNTSE1pV2t4RWN1T20rTS9LLzhBd0lHZ0Q2MzBYL2dsajRtazFaVjFmeHRwTnZwZ2JtU3l0NVpaaXZzcmJRRC9BTUNQNDE5RjY1NGkrRi83QXZ3bS9zK3dSWnRUbVV5UVdMU0tiL1ZaOFk4eVJnUGxRZDJ3RlVjS0NTQWZnblVQMjV2amhxVmliV1h4M05IR3d3V3Q3QzFoay83N1NJTVB3TmVMYTVyMnArSnRVbjFMVjlRdXRWMUdjN3BidTltYWFXUStyTXhKTkFIUi9GajRzZUl2alI0MHZQRTNpVzhOemV6bmJIRXVSRmJSQW5iRkd2OEFDb3o5U1NTU1NTYTQ2aWlnQW9vb29BS0tLS0FDaWlpZ0Fvb29vQUtLS0tBQ2lpaWdBb29vb0FLS0tLQVAvOWs9IiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJub25lIiBpZD0iZCIvPjwvZGVmcz48ZyBjbGlwLXBhdGg9InVybCgjYSkiIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0yMzggLTI0MSkiPjxnIGNsaXAtcGF0aD0idXJsKCNiKSIgdHJhbnNmb3JtPSJtYXRyaXgoLjAwMDEgMCAwIC4wMDAxIDIzOCAyNDIpIj48ZyBjbGlwLXBhdGg9InVybCgjYykiPjx1c2Ugd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgeGxpbms6aHJlZj0iI2QiIHRyYW5zZm9ybT0ic2NhbGUoNzA2Ni45NCkiLz48L2c+PC9nPjwvZz48L3N2Zz4=';
  
  export default {
    name: 'DisplayContent',
    components: {
      SmartImage,
    },
    props: {
      item: {
        type: Object,
        required: true
      }
    },
    computed: {
      logoUrl() {
        const img = this.item.logoUrl || defaultLinkLogo;
        return img;
      },
      truncatedTitle() {
        const title = this.item.title;
        return title.length > 50 ? title.slice(0, 50) + '...' : title ;
      },
      truncatedContent() {
        const content = this.item.linkDescription || this.item.introduction || '';
        return content;
      }
    }
  }
  </script>
  
  <style lang="scss" scoped>
  .display-content {
    border: 1px solid var(--card-border-color);
    border-radius: 8px;
    padding: 8px 10px;
    background: var(--background-primary);
    
    .title {
      font-size: 16px;
      font-weight: bold;
      margin-bottom: 5px;
      color: var(--font-color-primary);
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  
    .content-wrapper {
      display: flex;
      gap: 10px;
      margin-bottom: 12px;
      align-items: flex-start;
    }
  
    .logo-image {
      width: 40px;
      height: 40px;
      object-fit: cover;
      border-radius: 8px;
      flex-shrink: 0;
      margin-right: 10px;
    }
  
    .text-content {
      flex: 1;
      min-width: 0;
      max-width: calc(100% - 50px);
      overflow: hidden;
    }
  
    .description {
      font-size: 14px;
      color: var(--font-color-secondary);
      line-height: 1.5;
      margin: 0;
      word-wrap: break-word;
      word-break: break-all;
      white-space: normal;
      overflow: hidden;
    }
  }
  </style>