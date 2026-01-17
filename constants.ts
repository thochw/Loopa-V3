import { Users, Tent, Palette, Gamepad2, Coffee, Globe, MapPin, Calendar, MessageSquare, Search, Bell, Eye, Plus, Compass, List, Filter, Book, Backpack, ChevronRight, Share, Heart, Home, RefreshCw, UserPlus, Bed } from 'lucide-react';

export enum Tab {
  EXPLORE = 'explore',
  MAP = 'map',
  HOUSING = 'housing',
  CHATS = 'chats',
}

export const USERS = [
  { id: 1, name: 'Emily', distance: '1 mi', flag: '🇺🇸', image: 'https://i.pravatar.cc/150?u=emily', online: true, lng: -73.5700, lat: 45.5030 },
  { id: 2, name: 'Alissa Ma...', distance: '1 mi', flag: '🇬🇧', image: 'https://i.pravatar.cc/150?u=alissa', online: true, lng: -73.5600, lat: 45.5000 },
  { id: 3, name: 'Beatrice', distance: '14 mi', flag: '🇨🇦', image: 'https://i.pravatar.cc/150?u=beatrice', online: true, lng: -73.5800, lat: 45.5100 },
  { id: 4, name: 'John', distance: '0.5 mi', flag: '🇦🇺', image: 'https://i.pravatar.cc/150?u=john', online: true, lng: -73.5650, lat: 45.5020 },
  { id: 5, name: 'Sarah', distance: '2 mi', flag: '🇩🇪', image: 'https://i.pravatar.cc/150?u=sarah', online: true, lng: -73.5550, lat: 45.4950 },
];

export const GROUPS = [
  {
    id: 1,
    title: 'Cafés, gym, billiard',
    attendees: 2,
    image: 'https://images.unsplash.com/photo-1570554886111-e80fcca9402d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    avatars: ['https://i.pravatar.cc/150?u=a', 'https://i.pravatar.cc/150?u=b'],
    lng: -73.5620,
    lat: 45.5050
  },
  {
    id: 2,
    title: 'Weekly hangout, ( art, food, ro...',
    attendees: 7,
    image: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    avatars: ['https://i.pravatar.cc/150?u=c', 'https://i.pravatar.cc/150?u=d', 'https://i.pravatar.cc/150?u=e'],
    lng: -73.5750,
    lat: 45.4980
  }
];

export const HOUSING_SPOTS = [
  {
    id: 1,
    title: 'Sunny Studio in Plateau',
    price: 1200,
    currency: '$',
    period: 'mo',
    image: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    rating: 4.8,
    recommender: 'Sarah',
    recommenderImg: 'https://i.pravatar.cc/150?u=sarah',
    lat: 45.5200,
    lng: -73.5800,
    type: 'Entire place'
  },
  {
    id: 2,
    title: 'Room in Student Residence',
    price: 850,
    currency: '$',
    period: 'mo',
    image: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    rating: 4.2,
    recommender: 'John',
    recommenderImg: 'https://i.pravatar.cc/150?u=john',
    lat: 45.5050,
    lng: -73.5650,
    type: 'Private room'
  }
];

export const ROOMMATES = [
  {
    id: 1,
    name: 'Alex',
    age: 24,
    budget: 900,
    location: 'Downtown / Old Port',
    image: 'https://i.pravatar.cc/150?u=alex',
    tags: ['Student', 'Non-smoker', 'Quiet'],
    lat: 45.5000,
    lng: -73.5600,
    moveIn: 'Sept 1st'
  },
  {
    id: 2,
    name: 'Mia',
    age: 26,
    budget: 1300,
    location: 'Mile End',
    image: 'https://i.pravatar.cc/150?u=mia',
    tags: ['Professional', 'Pet friendly', 'Social'],
    lat: 45.5150,
    lng: -73.5900,
    moveIn: 'ASAP'
  }
];

export const SWAPS = [
  {
    id: 1,
    title: 'Modern Loft in Paris',
    target: 'Montreal',
    dates: 'Aug 10 - Aug 25',
    image: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    owner: 'Pierre',
    ownerImg: 'https://i.pravatar.cc/150?u=pierre',
    lat: 45.5100,
    lng: -73.5700,
    homeType: '1 Bedroom Apt'
  },
  {
    id: 2,
    title: 'Beach House in Barcelona',
    target: 'Montreal',
    dates: 'Sept 2024',
    image: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    owner: 'Elena',
    ownerImg: 'https://i.pravatar.cc/150?u=elena',
    lat: 45.4950,
    lng: -73.5800,
    homeType: 'Entire Home'
  }
];

export const CHATS = [
  {
    id: 1,
    title: 'Travel group',
    image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    message: 'Anyone in Montreal hosting an igloofest aft...',
    time: '3:05 PM',
    unread: true,
    type: 'group'
  },
  {
    id: 2,
    title: 'Emily',
    image: 'https://i.pravatar.cc/150?u=emily',
    message: 'Hey! Are we still meeting at the cafe?',
    time: '2:15 PM',
    unread: false,
    type: 'dm'
  },
  {
    id: 3,
    title: 'John',
    image: 'https://i.pravatar.cc/150?u=john',
    message: 'Sent you the itinerary for the weekend.',
    time: 'Yesterday',
    unread: true,
    type: 'dm'
  },
  {
    id: 4,
    title: 'Bali 2026',
    image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
    message: 'Sarah joined the group!',
    time: 'Yesterday',
    unread: false,
    type: 'group'
  }
];

export const CHAT_MESSAGES: Record<number, any[]> = {
  // Bali 2026
  4: [
    {
      id: 1,
      sender: 'Annie',
      senderAvatar: 'https://i.pravatar.cc/150?u=annie',
      text: 'And would anyone reccomend any good yoga retreats in uluawatu!!',
      time: '09:32',
      color: 'text-orange-500',
      isMe: false
    },
    {
        id: 2,
        sender: 'Natalie',
        senderAvatar: 'https://i.pravatar.cc/150?u=natalie',
        text: 'I think so maybee',
        time: '09:51',
        color: 'text-pink-500',
        isMe: false,
        replyTo: {
            sender: 'Ken',
            text: 'Thank you for your answer, you mean emoney card? I used it from public transport and toll payment also?'
        }
    },
    {
        id: 3,
        sender: 'Omurbek',
        senderAvatar: 'https://i.pravatar.cc/150?u=omurbek',
        text: 'Hello👋 anyone here ?',
        time: '11:18',
        color: 'text-yellow-500',
        isMe: false
    },
    {
        id: 4,
        type: 'separator',
        text: 'Today'
    },
    {
        id: 5,
        sender: 'Gypsy',
        senderAvatar: 'https://i.pravatar.cc/150?u=gypsy',
        text: 'Hi guys anyone keen to go la brisa beach club tonight for sunset and drinks ?',
        time: '00:32',
        color: 'text-blue-500',
        isMe: false
    },
    {
        id: 6,
        sender: 'Ayman',
        senderAvatar: 'https://i.pravatar.cc/150?u=ayman',
        text: "Let's go",
        time: '00:33',
        color: 'text-green-500',
        isMe: false
    },
    {
        id: 7,
        sender: 'Connor',
        senderAvatar: 'https://i.pravatar.cc/150?u=connor',
        text: 'Savaya tn if anyone interested dm me',
        time: '07:24',
        color: 'text-red-500',
        isMe: false
    }
  ],
  // Travel group
  1: [
      { id: 1, sender: 'Alex', senderAvatar: 'https://i.pravatar.cc/150?u=alex', text: 'Anyone in Montreal hosting an igloofest afterparty?', time: '3:05 PM', color: 'text-blue-500', isMe: false }
  ],
  // Emily
  2: [
      { id: 1, sender: 'Emily', senderAvatar: 'https://i.pravatar.cc/150?u=emily', text: 'Hey! Are we still meeting at the cafe?', time: '2:15 PM', color: 'text-gray-900', isMe: false }
  ],
  // John
  3: [
      { id: 1, sender: 'John', senderAvatar: 'https://i.pravatar.cc/150?u=john', text: 'Sent you the itinerary for the weekend.', time: 'Yesterday', color: 'text-gray-900', isMe: false }
  ]
};