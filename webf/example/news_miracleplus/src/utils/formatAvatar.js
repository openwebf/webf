export default function formatAvatar(avatar) {
  if (!avatar) {
    avatar = '/img/avatar/defaultavatar4.png';
  }
  if (avatar.startsWith('http')) {
    return avatar;
  }
  return `https://news.miracleplus.com${avatar}`;
}