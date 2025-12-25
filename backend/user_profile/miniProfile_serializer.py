from rest_framework import serializers
from .models import UserProfile



class MiniProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='userName.username',read_only=True)
    profileImage = serializers.SerializerMethodField()


    class Meta:
        model = UserProfile
        fields = ['id','username','profileImage']

    def get_profileImage(self,obj):
        if hasattr(obj,'profile',) and obj.profile.profileImage:
            return obj.profile.profileImage.url
        return None



